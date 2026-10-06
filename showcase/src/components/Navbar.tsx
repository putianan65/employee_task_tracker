import type { Lang } from '../content'
import { links } from '../content'
import { useLang } from '../i18n'
import { Reveal } from './Reveal'
import { Brand, monoLabel } from './ui'

const languages: { code: Lang; label: string; name: string }[] = [
  { code: 'th', label: 'TH', name: 'ภาษาไทย' },
  { code: 'en', label: 'EN', name: 'English' },
]

function LanguageToggle() {
  const { lang, setLang } = useLang()
  return (
    <div
      role="group"
      aria-label="Language"
      className="flex rounded-md border border-white/20 bg-white/10 p-0.5 backdrop-blur-md"
    >
      {languages.map((option) => {
        const active = option.code === lang
        return (
          <button
            key={option.code}
            type="button"
            lang={option.code}
            aria-label={option.name}
            aria-pressed={active}
            onClick={() => setLang(option.code)}
            className={`${monoLabel} rounded px-2 py-1 text-[10px] transition-colors duration-300 sm:px-2.5 sm:text-[11px] ${
              active ? 'bg-white text-black' : 'text-white/70 hover:text-white'
            }`}
          >
            {option.label}
          </button>
        )
      })}
    </div>
  )
}

export function Navbar() {
  const { t } = useLang()
  return (
    <header className="fixed inset-x-0 top-0 z-50 border-b border-white/15 bg-white/[0.03] backdrop-blur-md">
      <nav className="flex items-center justify-between gap-3 px-5 py-4 sm:px-8 md:px-12">
        <Reveal delay={0}>
          <a href="#top" aria-label="Employee Task Tracker">
            <Brand name="tasktracker" />
          </a>
        </Reveal>

        <ul className="hidden items-center gap-8 md:flex lg:gap-10">
          {t.nav.links.map((link, i) => (
            <Reveal as="li" key={link.href} delay={100 + i * 100}>
              <a
                href={link.href}
                className="text-sm text-white/85 transition-colors duration-300 hover:text-white"
              >
                {link.label}
                {link.count !== undefined && (
                  <sup className="ml-0.5 font-mono text-[10px] text-white/60">{link.count}</sup>
                )}
              </a>
            </Reveal>
          ))}
        </ul>

        <Reveal delay={500} className="flex items-center gap-2 sm:gap-3">
          <LanguageToggle />
          <a
            href={links.repo}
            target="_blank"
            rel="noreferrer"
            className="whitespace-nowrap rounded-md border border-white/20 bg-white/15 px-3 py-2 text-xs text-white backdrop-blur-md transition-colors duration-300 hover:bg-white/25 sm:px-5 sm:text-sm"
          >
            {t.nav.cta}
          </a>
        </Reveal>
      </nav>
    </header>
  )
}
