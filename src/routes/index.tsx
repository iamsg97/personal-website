import { createFileRoute } from '@tanstack/react-router'
import About from '../components/About'
import { AnimatedSection } from '../components/AnimatedSection'
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
          <AnimatedSection animation="zoom" delay={200}>
            <h1 className="text-4xl font-bold tracking-tight sm:text-5xl md:text-6xl">
              <span className="block">Welcome to My Personal Website</span>
              <span className="text-accent mt-2 block">Full Stack Developer</span>
            </h1>
          </AnimatedSection>

          <AnimatedSection animation="slideUp" delay={400}>
            <p className="mx-auto mt-6 max-w-2xl text-lg">
              I build modern web applications using TypeScript, React, and other cutting-edge
              technologies.
            </p>
          </AnimatedSection>

          <AnimatedSection animation="fade" delay={600}>
            <div className="mt-10 flex justify-center gap-4">
              <Button size="lg" onClick={() => scrollToSection('projects')}>
                View My Work
              </Button>
              <Button variant="outline" size="lg" onClick={() => scrollToSection('contact')}>
                Contact Me
              </Button>
            </div>
          </AnimatedSection>
        </div>
      </section>

      {/* About Section */}
      <AnimatedSection animation="zoom">
        <About />
      </AnimatedSection>

      {/* Skills Section */}
      <AnimatedSection animation="slideUp" delay={100}>
        <Skills />
      </AnimatedSection>

      {/* Projects Section */}
      <AnimatedSection animation="zoom" delay={200}>
        <Projects />
      </AnimatedSection>

      {/* Contact Section */}
      <AnimatedSection animation="slideUp" delay={100}>
        <Contact />
      </AnimatedSection>
    </div>
  )
}
