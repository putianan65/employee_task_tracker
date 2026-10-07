import { useState, type ReactNode } from 'react'
import { ChevronRight, Hexagon } from 'lucide-react'

export const sectionShell =
  'relative flex min-h-screen supports-[height:100svh]:min-h-[100svh] flex-col justify-between px-5 sm:px-8 md:px-12 pt-24 sm:pt-28 pb-12 md:pb-16'

export const headline =
  'text-5xl sm:text-6xl lg:text-7xl font-normal leading-[1.05] tracking-tight text-white drop-shadow-lg'

export const monoLabel = 'font-mono uppercase tracking-[0.15em]'

// Left-accent glass badge.
export function Badge({ children }: { children: ReactNode }) {
  return (
    <span
      className={`inline-block border-l-2 border-white bg-white/15 px-3 py-1.5 backdrop-blur-md ${monoLabel} text-[11px] text-white`}
    >
      {children}
    </span>
  )
}

type LinkButtonProps = { href: string; children: ReactNode; className?: string }

function external(href: string) {
  return href.startsWith('http') ? { target: '_blank', rel: 'noreferrer' } : {}
}

export function PrimaryButton({ href, children, className = '' }: LinkButtonProps) {
  return (
    <a
      href={href}
      {...external(href)}
      className={`inline-flex w-fit items-center gap-1 rounded-full bg-white font-medium text-black transition-colors duration-300 hover:bg-white/85 ${className}`}
    >
      {children}
      <ChevronRight size={14} aria-hidden="true" />
    </a>
  )
}

export function SecondaryButton({ href, children, className = '' }: LinkButtonProps) {
  return (
    <a
      href={href}
      {...external(href)}
      className={`inline-flex w-fit items-center rounded-full border border-white/25 bg-white/10 text-white backdrop-blur-md transition-colors duration-300 hover:bg-white/20 ${className}`}
    >
      {children}
    </a>
  )
}

export function Brand({ name }: { name: string }) {
  return (
    <span className="flex items-center gap-2 text-white">
      <Hexagon size={24} strokeWidth={1.5} aria-hidden="true" />
      <span className="text-lg font-medium tracking-tight sm:text-xl">{name}</span>
    </span>
  )
}

// Frosted "browser window" around a desktop screenshot.
export function ScreenFrame({ src, alt }: { src: string; alt: string }) {
  return (
    <figure className="rounded-2xl border border-white/15 bg-white/10 p-1.5 shadow-2xl shadow-black/40 backdrop-blur-md sm:p-2">
      <div aria-hidden="true" className="flex gap-1.5 px-2 pb-2 pt-1">
        <span className="h-2 w-2 rounded-full bg-white/30" />
        <span className="h-2 w-2 rounded-full bg-white/20" />
        <span className="h-2 w-2 rounded-full bg-white/10" />
      </div>
      <img
        src={src}
        alt={alt}
        width={1600}
        height={1000}
        loading="lazy"
        decoding="async"
        className="block h-auto w-full rounded-xl"
      />
    </figure>
  )
}

// Frosted phone frame around a mobile screenshot.
export function PhoneFrame({ src, alt, className = '' }: { src: string; alt: string; className?: string }) {
  return (
    <figure
      className={`rounded-[1.75rem] border border-white/20 bg-white/10 p-1.5 shadow-2xl shadow-black/40 backdrop-blur-md ${className}`}
    >
      <img
        src={src}
        alt={alt}
        width={780}
        height={1688}
        loading="lazy"
        decoding="async"
        className="block h-auto w-full rounded-[1.4rem]"
      />
    </figure>
  )
}

// Portrait slot (h-24 w-20) with a quiet fallback if the image can't load.
export function Portrait({ src, alt }: { src: string; alt: string }) {
  const [failed, setFailed] = useState(false)
  if (failed) {
    return (
      <div
        role="img"
        aria-label={alt}
        className="flex h-24 w-20 shrink-0 items-center justify-center rounded-lg bg-white/10"
      >
        <Hexagon size={28} strokeWidth={1.5} className="text-white/70" aria-hidden="true" />
      </div>
    )
  }
  return (
    <img
      src={src}
      alt={alt}
      onError={() => setFailed(true)}
      className="h-24 w-20 shrink-0 rounded-lg object-cover"
    />
  )
}
