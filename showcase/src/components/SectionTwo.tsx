import { ChevronRight } from 'lucide-react'
import { links } from '../content'
import { useLang } from '../i18n'
import { Reveal } from './Reveal'
import { Badge, PrimaryButton, SecondaryButton, headline, monoLabel, sectionShell } from './ui'

// The problem the app solves, and the three questions it answers.
export function SectionTwo() {
  const { t } = useLang()
  const why = t.why
  return (
    <section id="why" className={sectionShell}>
      <div className="flex flex-col gap-8 sm:flex-row sm:justify-between">
        <Reveal delay={120}>
          <Badge>{why.badge}</Badge>
        </Reveal>
        <Reveal delay={220} className="max-w-sm sm:text-right">
          <p className="text-lg leading-relaxed text-white drop-shadow-md sm:text-xl">{why.intro}</p>
        </Reveal>
      </div>

      <div className="flex flex-1 flex-col justify-end gap-12 pt-12 md:flex-row md:items-end md:justify-between md:gap-16">
        <div className="max-w-xl">
          <Reveal as="h2" delay={180} className={headline}>
            {why.headline[0]}
            <br />
            {why.headline[1]}
          </Reveal>
          <Reveal
            as="p"
            delay={320}
            className="mt-6 max-w-md text-sm leading-relaxed text-white/80 drop-shadow-md sm:text-base"
          >
            {why.body}
          </Reveal>
          <Reveal delay={420} className="mt-8 flex flex-wrap gap-3">
            <PrimaryButton href="#walkthrough" className="px-5 py-2.5 text-xs sm:text-sm">
              {why.primary}
            </PrimaryButton>
            <SecondaryButton href={links.repo} className="px-5 py-2.5 text-xs sm:text-sm">
              {why.secondary}
            </SecondaryButton>
          </Reveal>
        </div>

        <div className="w-full max-w-md rounded-2xl border border-white/15 bg-white/10 px-5 backdrop-blur-md sm:px-6">
          {why.items.map((item, i) => (
            <Reveal
              key={item.title}
              delay={300 + i * 110}
              className={`group flex gap-5 py-5 ${
                i < why.items.length - 1 ? 'border-b border-white/15' : ''
              }`}
            >
              <span className={`${monoLabel} pt-1 text-[11px] text-white/55`}>
                {String(i + 1).padStart(2, '0')}
              </span>
              <div>
                <h3 className="flex items-center gap-1.5 text-base font-medium text-white sm:text-lg">
                  {item.title}
                  <ChevronRight
                    size={16}
                    aria-hidden="true"
                    className="text-white/40 transition-all duration-300 group-hover:translate-x-0.5 group-hover:text-white"
                  />
                </h3>
                <p className="mt-1.5 text-sm leading-relaxed text-white/70">{item.body}</p>
              </div>
            </Reveal>
          ))}
        </div>
      </div>
    </section>
  )
}
