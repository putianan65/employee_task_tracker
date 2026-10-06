import { author, links } from '../content'
import { useLang } from '../i18n'
import { Reveal } from './Reveal'
import { Badge, PrimaryButton, Portrait, headline, monoLabel, sectionShell } from './ui'

export function SectionOne() {
  const { t } = useLang()
  const hero = t.hero
  return (
    <section id="top" className={sectionShell}>
      <div className="flex flex-col gap-8 sm:flex-row sm:justify-between">
        <ul className="flex flex-col gap-2">
          {hero.services.map((service, i) => (
            <Reveal
              as="li"
              key={service}
              delay={150 + i * 120}
              className={`${monoLabel} text-xs text-white/90 drop-shadow-md`}
            >
              / {service}
            </Reveal>
          ))}
        </ul>

        <Reveal delay={300} className="max-w-xs sm:text-right">
          <p className="text-lg leading-relaxed text-white drop-shadow-md sm:text-xl">{hero.intro}</p>
        </Reveal>
      </div>

      <div className="flex flex-col gap-8 md:flex-row md:items-end md:justify-between">
        <div>
          <Reveal delay={150} className="mb-5">
            <Badge>{hero.badge}</Badge>
          </Reveal>
          <Reveal as="h1" delay={280} className={headline}>
            {hero.headline[0]}
            <br />
            {hero.headline[1]}
          </Reveal>
        </div>

        <Reveal delay={420}>
          <div className="flex w-fit items-center gap-4 rounded-xl bg-white/15 p-3 backdrop-blur-md">
            <Portrait src={author.avatar} alt={`${author.handle} — GitHub avatar`} />
            <div className="flex flex-col gap-1.5 pr-2">
              <p className="text-sm font-medium text-white">
                {hero.builtBy} {author.handle}
              </p>
              <p className={`${monoLabel} text-[10px] text-white/60`}>{hero.cardMeta}</p>
              <PrimaryButton href={links.repo} className="mt-1.5 px-4 py-2 text-xs">
                {hero.cardCta}
              </PrimaryButton>
            </div>
          </div>
        </Reveal>
      </div>
    </section>
  )
}
