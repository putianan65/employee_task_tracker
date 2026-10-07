import { createContext, useContext, useEffect, useState, type ReactNode } from 'react'
import { copy, type Copy, type Lang } from './content'

const STORAGE_KEY = 'showcase-lang'

type LangContextValue = { lang: Lang; setLang: (lang: Lang) => void; t: Copy }

const LangContext = createContext<LangContextValue | null>(null)

function isLang(value: unknown): value is Lang {
  return value === 'th' || value === 'en'
}

// Thai by default; `?lang=en` or a remembered choice overrides it.
function initialLang(): Lang {
  const fromUrl = new URLSearchParams(window.location.search).get('lang')
  if (isLang(fromUrl)) return fromUrl
  try {
    const stored = window.localStorage.getItem(STORAGE_KEY)
    if (isLang(stored)) return stored
  } catch {
    // Storage can be unavailable (private mode, blocked site data).
  }
  return 'th'
}

export function LangProvider({ children }: { children: ReactNode }) {
  const [lang, setLangState] = useState<Lang>(initialLang)

  useEffect(() => {
    document.documentElement.lang = lang
    document.title = copy[lang].title
  }, [lang])

  const setLang = (next: Lang) => {
    setLangState(next)
    try {
      window.localStorage.setItem(STORAGE_KEY, next)
    } catch {
      // Ignore — the choice just won't be remembered.
    }
  }

  return <LangContext.Provider value={{ lang, setLang, t: copy[lang] }}>{children}</LangContext.Provider>
}

export function useLang() {
  const value = useContext(LangContext)
  if (!value) throw new Error('useLang must be used inside <LangProvider>')
  return value
}
