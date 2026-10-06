import { useLang } from '../i18n'
import { Reveal } from './Reveal'
import { Badge, headline, monoLabel } from './ui'

export function Stack() {
  const { t } = useLang()
  const s = t.stack
  return (
    <section id="stack" className="relative px-5 pb-12 pt-24 sm:px-8 sm:pt-28 md:px-12 md:pb-16">
      <div className="grid items-end gap-12 md:grid-cols-2 md:gap-16">
        <div className="max-w-xl">
          <Reveal delay={120} className="mb-5">
            <Badge>{s.badge}</Badge>
          </Reveal>
          <Reveal as="h2" delay={180} className={headline}>
            {s.headline[0]}
            <br />
            {s.headline[1]}
          </Reveal>
          <Reveal
            as="p"
            delay={260}
            className="mt-6 max-w-md text-sm leading-relaxed text-white/80 drop-shadow-md sm:text-base"
          >
            {s.body}
          </Reveal>

          <Reveal delay={320} className={`${monoLabel} mt-10 text-[11px] text-white/55`}>
            {s.learningsLabel}
          </Reveal>
          <ul className="mt-3 flex flex-col gap-2">
            {s.learnings.map((item, i) => (
              <Reveal
                as="li"
                key={item}
                delay={360 + i * 80}
                className={`${monoLabel} text-xs text-white/90 drop-shadow-md`}
              >
                / {item}
              </Reveal>
            ))}
          </ul>
        </div>

        <dl className="w-full rounded-2xl border border-white/15 bg-white/10 px-5 backdrop-blur-md sm:px-6 md:justify-self-end md:max-w-lg">
          {s.items.map((row, i) => (
            <Reveal
              key={row.label}
              delay={250 + i * 90}
              className={`flex items-baseline justify-between gap-6 py-4 ${
                i < s.items.length - 1 ? 'border-b border-white/15' : ''
              }`}
            >
              <dt className={`${monoLabel} shrink-0 text-[11px] text-white/55`}>{row.label}</dt>
              <dd className="text-right text-sm text-white sm:text-base">{row.value}</dd>
            </Reveal>
          ))}
        </dl>
      </div>
    </section>
  )
}
