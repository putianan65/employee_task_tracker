import { author, links } from '../content'
import { useLang } from '../i18n'
import { Reveal } from './Reveal'
import { Badge, Brand, monoLabel } from './ui'

export function Footer() {
  const { t } = useLang()
  const f = t.footer
  const footerLinks = [
    { label: 'GitHub', href: links.repo },
    { label: f.readmeEn, href: links.readmeEn },
    { label: f.readmeTh, href: links.readmeTh },
    { label: f.profile, href: links.profile },
  ]
  return (
    <footer id="credits" className="relative px-5 pb-12 pt-24 sm:px-8 sm:pt-28 md:px-12 md:pb-16">
      <Reveal delay={100}>
        <div className="rounded-2xl border border-white/15 bg-white/10 p-5 backdrop-blur-md sm:p-8">
          <div className="flex flex-col gap-6 md:flex-row md:items-start md:justify-between">
            <div>
              <Brand name="tasktracker" />
              <p className="mt-3 max-w-sm text-sm leading-relaxed text-white/70">{f.tagline}</p>
            </div>
            <ul className="flex flex-wrap gap-x-6 gap-y-2">
              {footerLinks.map((link) => (
                <li key={link.href}>
                  <a
                    href={link.href}
                    target="_blank"
                    rel="noreferrer"
                    className="text-sm text-white/85 transition-colors duration-300 hover:text-white"
                  >
                    {link.label}
                  </a>
                </li>
              ))}
            </ul>
          </div>

          <div className="mt-10">
            <Badge>{f.creditsLabel}</Badge>
            <dl className="mt-6 grid gap-x-10 gap-y-5 sm:grid-cols-2 lg:grid-cols-3">
              {f.credits.map((credit) => (
                <div key={credit.label}>
                  <dt className={`${monoLabel} text-[11px] text-white/55`}>{credit.label}</dt>
                  <dd className="mt-1.5 text-sm leading-relaxed text-white/80">{credit.body}</dd>
                </div>
              ))}
            </dl>
          </div>

          <div className="mt-10 flex flex-col gap-2 border-t border-white/15 pt-5 text-xs text-white/55 sm:flex-row sm:justify-between">
            <p>
              © {author.handle} · {f.rights}
            </p>
            <p>{f.adapted}</p>
          </div>
        </div>
      </Reveal>
    </footer>
  )
}
