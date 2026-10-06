import { Features } from './components/Features'
import { Footer } from './components/Footer'
import { Navbar } from './components/Navbar'
import { ScrollVideo } from './components/ScrollVideo'
import { SectionOne } from './components/SectionOne'
import { SectionTwo } from './components/SectionTwo'
import { Stack } from './components/Stack'
import { Walkthrough } from './components/Walkthrough'
import { LangProvider } from './i18n'

export default function App() {
  return (
    <LangProvider>
      <div className="relative">
        <ScrollVideo />
        <div className="relative z-10">
          <Navbar />
          <main>
            <SectionOne />
            {/* Scroll room for the video to scrub between hero and section two. */}
            <div aria-hidden="true" className="h-[80vh]" />
            <SectionTwo />
            <Walkthrough />
            <Features />
            <Stack />
          </main>
          <Footer />
        </div>
      </div>
    </LangProvider>
  )
}
