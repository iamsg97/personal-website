import { createFileRoute } from '@tanstack/react-router'
import About from '../components/About'
import Contact from '../components/Contact'
import Projects from '../components/Projects'
import Skills from '../components/Skills'
import { Button } from '../components/ui/button'

export const Route = createFileRoute('/')({
  component: HomePage,
})

function HomePage() {
  // Handle scroll to section
  const scrollToSection = (sectionId: string) => {
    const element = document.getElementById(sectionId)
    if (element) {
      element.scrollIntoView({ behavior: 'smooth' })
    }
  }

  return (
    <div>
      {/* Hero Section */}
      <section className="px-4 py-20">
        <div className="mx-auto max-w-5xl text-center">
          <h1 className="text-4xl font-bold tracking-tight sm:text-5xl md:text-6xl">
            <span className="block">Welcome to My Personal Website</span>
            <span className="text-accent mt-2 block">Full Stack Developer</span>
          </h1>
          <p className="mx-auto mt-6 max-w-2xl text-lg">
            I build modern web applications using TypeScript, React, and other cutting-edge
            technologies.
          </p>
          <div className="mt-10 flex justify-center gap-4">
            <Button size="lg" onClick={() => scrollToSection('projects')}>
              View My Work
            </Button>
            <Button variant="outline" size="lg" onClick={() => scrollToSection('contact')}>
              Contact Me
            </Button>
          </div>
        </div>
      </section>

      {/* About Section */}
      <About />

      {/* Skills Section */}
      <Skills />

      {/* Projects Section */}
      <Projects />

      {/* Contact Section */}
      <Contact />
    </div>
  )
}
