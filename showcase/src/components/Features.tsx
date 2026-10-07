import { screens } from '../content'
import { useLang } from '../i18n'
import { Reveal } from './Reveal'
import { Badge, PhoneFrame, headline, monoLabel } from './ui'

export function Features() {
  const { t } = useLang()
  const f = t.features
  return (
    <section id="features" className="relative px-5 pb-12 pt-24 sm:px-8 sm:pt-28 md:px-12 md:pb-16">
      <div className="flex flex-col gap-8 md:flex-row md:items-end md:justify-between">
        <div>
          <Reveal delay={120} className="mb-5">
            <Badge>{f.badge}</Badge>
          </Reveal>
          <Reveal as="h2" delay={180} className={headline}>
            {f.headline[0]}
            <br />
            {f.headline[1]}
          </Reveal>
        </div>
        <Reveal delay={260} className="max-w-sm md:text-right">
          <p className="text-lg leading-relaxed text-white drop-shadow-md sm:text-xl">{f.body}</p>
        </Reveal>
      </div>

      <div className="mt-16 grid items-start gap-12 lg:grid-cols-12">
        <Reveal delay={150} className="lg:col-span-5">
          <div className="flex items-start justify-center gap-4 sm:gap-6">
            <PhoneFrame src={screens.mobileList} alt={f.mobileAlt[0]} className="w-[46%] max-w-[230px]" />
            <PhoneFrame
              src={screens.mobileDetail}
              alt={f.mobileAlt[1]}
              className="mt-10 w-[46%] max-w-[230px]"
            />
          </div>
          <p className={`${monoLabel} mt-6 text-center text-[11px] text-white/60 drop-shadow-md`}>
            {f.mobileCaption}
          </p>
        </Reveal>

        <ol className="grid rounded-2xl border border-white/15 bg-white/10 px-5 backdrop-blur-md sm:grid-cols-2 sm:gap-x-8 sm:px-6 lg:col-span-7">
          {f.items.map((item, i) => (
            <Reveal
              as="li"
              key={item.title}
              delay={150 + i * 60}
              className="flex gap-4 border-t border-white/15 py-5 first:border-t-0 sm:[&:nth-child(2)]:border-t-0"
            >
              <span className={`${monoLabel} pt-0.5 text-[11px] text-white/55`}>
                {String(i + 1).padStart(2, '0')}
              </span>
              <div>
                <h3 className="text-base font-medium text-white">{item.title}</h3>
                <p className="mt-1 text-sm leading-relaxed text-white/70">{item.body}</p>
              </div>
            </Reveal>
          ))}
        </ol>
      </div>
    </section>
  )
}
