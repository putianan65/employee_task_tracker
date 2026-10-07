import { useEffect, useRef, useState } from 'react'
import { heroVideoSrc } from '../content'

const MAX_FRAMES = 90
const MIN_FRAMES = 24
const FRAMES_PER_SECOND = 12
const MAX_FRAME_WIDTH = 960
const LERP = 0.12
const SEEK_EPSILON = 0.04
const END_PADDING = 0.05
const EXTRACT_DELAY_MS = 300
const SEEK_TIMEOUT_MS = 4000

function clamp01(n: number) {
  return Math.min(1, Math.max(0, n))
}

function readProgress() {
  const max = document.documentElement.scrollHeight - window.innerHeight
  return max > 0 ? clamp01(window.scrollY / max) : 0
}

// Draws the source with object-cover math: scale to fill, center crop.
function drawCover(
  ctx: CanvasRenderingContext2D,
  source: CanvasImageSource & { width: number; height: number },
  cw: number,
  ch: number,
) {
  const scale = Math.max(cw / source.width, ch / source.height)
  const dw = source.width * scale
  const dh = source.height * scale
  ctx.drawImage(source, (cw - dw) / 2, (ch - dh) / 2, dw, dh)
}

function waitFor(el: HTMLMediaElement, event: string, signal: AbortSignal) {
  return new Promise<void>((resolve, reject) => {
    const timer = window.setTimeout(() => finish(new Error(`timeout: ${event}`)), SEEK_TIMEOUT_MS)
    const onEvent = () => finish()
    const onError = () => finish(new Error('video error'))
    const onAbort = () => finish(new DOMException('aborted', 'AbortError'))
    function finish(err?: unknown) {
      window.clearTimeout(timer)
      el.removeEventListener(event, onEvent)
      el.removeEventListener('error', onError)
      signal.removeEventListener('abort', onAbort)
      if (err) reject(err)
      else resolve()
    }
    el.addEventListener(event, onEvent, { once: true })
    el.addEventListener('error', onError, { once: true })
    signal.addEventListener('abort', onAbort, { once: true })
  })
}

// Decodes evenly spaced frames from an offscreen copy of the video so
// scrubbing can draw bitmaps instead of seeking the visible <video>.
async function extractFrames(src: string, signal: AbortSignal) {
  const video = document.createElement('video')
  video.muted = true
  video.playsInline = true
  video.preload = 'auto'
  video.src = src

  const frames: ImageBitmap[] = []
  try {
    if (video.readyState < 2) await waitFor(video, 'loadeddata', signal)

    const duration = video.duration
    if (!Number.isFinite(duration) || duration <= 0) throw new Error('unknown duration')

    const count = Math.min(MAX_FRAMES, Math.max(MIN_FRAMES, Math.round(duration * FRAMES_PER_SECOND)))
    const scale = Math.min(1, MAX_FRAME_WIDTH / video.videoWidth)
    const scratch = document.createElement('canvas')
    scratch.width = Math.round(video.videoWidth * scale)
    scratch.height = Math.round(video.videoHeight * scale)
    const scratchCtx = scratch.getContext('2d')
    if (!scratchCtx) throw new Error('no 2d context')

    for (let i = 0; i < count; i++) {
      video.currentTime = (i / (count - 1)) * Math.max(0, duration - END_PADDING)
      await waitFor(video, 'seeked', signal)
      scratchCtx.drawImage(video, 0, 0, scratch.width, scratch.height)
      frames.push(await createImageBitmap(scratch))
    }
    return frames
  } catch (err) {
    frames.forEach((f) => f.close())
    throw err
  } finally {
    video.removeAttribute('src')
    video.load()
  }
}

// Fixed, full-bleed background whose timeline is driven by page scroll only.
// Layers: mist poster → <video> (seek fallback) → <canvas> (cached frames).
export function ScrollVideo({ src = heroVideoSrc }: { src?: string }) {
  const posterRef = useRef<HTMLDivElement>(null)
  const videoRef = useRef<HTMLVideoElement>(null)
  const canvasRef = useRef<HTMLCanvasElement>(null)
  const framesRef = useRef<ImageBitmap[]>([])
  const kickRef = useRef<() => void>(() => {})
  const [hasFrame, setHasFrame] = useState(false)
  const [framesReady, setFramesReady] = useState(false)

  // Scroll → smoothed progress → draw a cached frame, or seek the video.
  useEffect(() => {
    const video = videoRef.current
    const canvas = canvasRef.current
    const poster = posterRef.current
    if (!video || !canvas || !poster) return
    const ctx = canvas.getContext('2d')

    let target = readProgress()
    let smoothed = target
    let raf = 0
    let lastIndex = -1
    let canvasStale = true

    const tick = () => {
      raf = 0
      target = readProgress()
      smoothed += (target - smoothed) * LERP
      const settled = Math.abs(target - smoothed) < 0.0005
      if (settled) smoothed = target

      poster.style.setProperty('--p', smoothed.toFixed(4))

      const frames = framesRef.current
      if (frames.length > 0 && ctx) {
        if (canvasStale) {
          const dpr = Math.min(window.devicePixelRatio || 1, 2)
          canvas.width = Math.round(window.innerWidth * dpr)
          canvas.height = Math.round(window.innerHeight * dpr)
          canvasStale = false
          lastIndex = -1
        }
        const index = Math.round(smoothed * (frames.length - 1))
        if (index !== lastIndex) {
          drawCover(ctx, frames[index], canvas.width, canvas.height)
          lastIndex = index
        }
      } else if (video.readyState >= 1 && Number.isFinite(video.duration) && video.duration > 0) {
        const time = smoothed * Math.max(0, video.duration - END_PADDING)
        if (!video.seeking && Math.abs(video.currentTime - time) > SEEK_EPSILON) {
          video.currentTime = time
        }
      }

      if (!settled) raf = requestAnimationFrame(tick)
    }

    const kick = () => {
      if (!raf) raf = requestAnimationFrame(tick)
    }
    const onResize = () => {
      canvasStale = true
      kick()
    }
    kickRef.current = kick

    window.addEventListener('scroll', kick, { passive: true })
    window.addEventListener('resize', onResize)
    video.addEventListener('loadedmetadata', kick)
    video.addEventListener('seeked', kick)
    kick()

    return () => {
      cancelAnimationFrame(raf)
      window.removeEventListener('scroll', kick)
      window.removeEventListener('resize', onResize)
      video.removeEventListener('loadedmetadata', kick)
      video.removeEventListener('seeked', kick)
      kickRef.current = () => {}
    }
  }, [])

  // Once the visible video has a decoded frame, build the frame cache.
  useEffect(() => {
    const video = videoRef.current
    if (!video) return
    const controller = new AbortController()
    let timer = 0

    const onLoadedData = () => {
      setHasFrame(true)
      timer = window.setTimeout(() => {
        extractFrames(src, controller.signal)
          .then((frames) => {
            framesRef.current = frames
            setFramesReady(true)
            kickRef.current()
          })
          .catch(() => {
            // Keep using the seek fallback on the visible <video>.
          })
      }, EXTRACT_DELAY_MS)
    }

    // Some mobile browsers will not decode a first frame until playback is
    // attempted; prime it once and pause immediately (no autoplay).
    const onLoadedMetadata = () => {
      if (video.readyState < 2) {
        video
          .play()
          .then(() => video.pause())
          .catch(() => {})
      }
    }

    if (video.readyState >= 2) onLoadedData()
    else video.addEventListener('loadeddata', onLoadedData, { once: true })
    video.addEventListener('loadedmetadata', onLoadedMetadata, { once: true })

    return () => {
      controller.abort()
      window.clearTimeout(timer)
      video.removeEventListener('loadeddata', onLoadedData)
      video.removeEventListener('loadedmetadata', onLoadedMetadata)
      framesRef.current.forEach((f) => f.close())
      framesRef.current = []
    }
  }, [src])

  return (
    <div
      aria-hidden="true"
      className="pointer-events-none fixed inset-0 z-0 overflow-hidden bg-[#0a0a0a]"
    >
      <div
        ref={posterRef}
        className={`mist-poster absolute inset-0 transition-opacity duration-500 ${
          hasFrame || framesReady ? 'opacity-0' : 'opacity-100'
        }`}
      >
        <span className="bokeh left-[12%] top-[22%] h-3 w-3" />
        <span className="bokeh left-[78%] top-[18%] h-2 w-2" />
        <span className="bokeh left-[62%] top-[74%] h-4 w-4" />
        <span className="bokeh left-[28%] top-[68%] h-2 w-2" />
        <span className="bokeh left-[88%] top-[48%] h-3 w-3" />
        <span className="bokeh left-[44%] top-[12%] h-1.5 w-1.5" />
      </div>
      <video
        ref={videoRef}
        src={src}
        muted
        playsInline
        preload="auto"
        className={`absolute inset-0 h-full w-full object-cover transition-opacity duration-500 ${
          hasFrame && !framesReady ? 'opacity-100' : 'opacity-0'
        }`}
      />
      <canvas
        ref={canvasRef}
        className={`absolute inset-0 h-full w-full transition-opacity duration-500 ${
          framesReady ? 'opacity-100' : 'opacity-0'
        }`}
      />
    </div>
  )
}
