import { useLang } from '../i18n'
import { Reveal } from './Reveal'
import { Badge, ScreenFrame, headline, monoLabel } from './ui'

// "How it works": each step pairs a real app screenshot with what to do.
export function Walkthrough() {
  const { t } = useLang()
  const w = t.walkthrough
  return (
    <section id="walkthrough" className="relative px-5 pb-12 pt-24 sm:px-8 sm:pt-28 md:px-12 md:pb-16">
      <div className="flex flex-col gap-8 md:flex-row md:items-end md:justify-between">
        <div>
          <Reveal delay={120} className="mb-5">
            <Badge>{w.badge}</Badge>
          </Reveal>
          <Reveal as="h2" delay={180} className={headline}>
            {w.headline[0]}
            <br />
            {w.headline[1]}
          </Reveal>
        </div>
        <Reveal delay={260} className="max-w-sm md:text-right">
          <p className="text-lg leading-relaxed text-white drop-shadow-md sm:text-xl">{w.intro}</p>
          <p className="mt-3 text-sm leading-relaxed text-white/60 drop-shadow-md">{w.note}</p>
        </Reveal>
      </div>

      <ol className="mt-16 flex flex-col gap-20 md:mt-24 md:gap-28">
        {w.steps.map((step, i) => {
          const flipped = i % 2 === 1
          return (
            <li key={step.image} className="grid items-center gap-8 md:grid-cols-12 md:gap-12">
              <Reveal delay={120} className={`md:col-span-7 ${flipped ? 'md:order-2' : ''}`}>
                <ScreenFrame src={step.image} alt={step.alt} />
              </Reveal>
              <div className={`md:col-span-5 ${flipped ? 'md:order-1' : ''}`}>
                <Reveal delay={200} className={`${monoLabel} text-[11px] text-white/60 drop-shadow-md`}>
                  {w.stepLabel} {String(i + 1).padStart(2, '0')} · {step.role}
                </Reveal>
                <Reveal
                  as="h3"
                  delay={260}
                  className="mt-3 text-3xl font-normal tracking-tight text-white drop-shadow-lg sm:text-4xl"
                >
                  {step.title}
                </Reveal>
                <Reveal
                  as="p"
                  delay={320}
                  className="mt-4 text-sm leading-relaxed text-white/80 drop-shadow-md sm:text-base"
                >
                  {step.body}
                </Reveal>
                <Reveal as="ul" delay={380} className="mt-5 flex flex-wrap gap-2">
                  {step.tags.map((tag) => (
                    <li
                      key={tag}
                      className={`${monoLabel} rounded-full border border-white/20 bg-white/10 px-3 py-1 text-[10px] text-white/80 backdrop-blur-md`}
                    >
                      {tag}
                    </li>
                  ))}
                </Reveal>
              </div>
            </li>
          )
        })}
      </ol>
    </section>
  )
}
