import { useEffect, useState } from 'react'

import { NAV_SECTIONS } from '../constants/links'
import { ThemeToggle } from './ThemeToggle'

export default function Header() {
  const [isMenuOpen, setIsMenuOpen] = useState(false)
  const [scrolled, setScrolled] = useState(false)

  // Handle scroll effect
  useEffect(() => {
    const handleScroll = () => {
      setScrolled(window.scrollY > 10)
    }

    window.addEventListener('scroll', handleScroll)
    return () => window.removeEventListener('scroll', handleScroll)
  }, [])
  // Close mobile menu when clicking on a navigation link
  const handleNavClick = () => {
    setIsMenuOpen(false)
  }

  // Handle scroll to section
  const scrollToSection = (sectionId: string) => {
    const element = document.getElementById(sectionId)
    if (element) {
      element.scrollIntoView({ behavior: 'smooth' })
    }
    handleNavClick()
  }

  // Handle scroll to top
  const scrollToTop = () => {
    window.scrollTo({
      top: 0,
      behavior: 'smooth',
    })
    handleNavClick()
  }

  return (
    <header
      className={`bg-background sticky top-0 z-40 border-b ${scrolled ? 'shadow-sm' : ''} transition-shadow`}
    >
      <div className="container mx-auto flex h-16 max-w-7xl items-center px-4 sm:px-6 lg:px-8">
        {/* Logo on the left */}
        <div>
          <button
            type="button"
            onClick={scrollToTop}
            className="hover:text-accent text-xl font-bold transition-colors"
          >
            <img
              src="/public/webheadshot.png"
              alt="Logo"
              className="mr-2 inline-block h-8 w-8 rounded-full align-middle"
            />
            SG
          </button>
        </div>
        {/* Navigation centered - desktop */}
        <div className="flex flex-1 justify-center">
          {' '}
          <nav className="hidden items-center gap-6 text-sm md:flex">
            <button
              type="button"
              onClick={scrollToTop}
              className="hover:text-accent font-medium transition-colors"
            >
              Home
            </button>
            <button
              type="button"
              onClick={() => scrollToSection(NAV_SECTIONS.about)}
              className="hover:text-accent font-medium transition-colors"
            >
              About
            </button>
            <button
              type="button"
              onClick={() => scrollToSection(NAV_SECTIONS.skills)}
              className="hover:text-accent font-medium transition-colors"
            >
              Skills
            </button>
            <button
              type="button"
              onClick={() => scrollToSection(NAV_SECTIONS.projects)}
              className="hover:text-accent font-medium transition-colors"
            >
              Projects
            </button>
            <button
              type="button"
              onClick={() => scrollToSection(NAV_SECTIONS.contact)}
              className="hover:text-accent font-medium transition-colors"
            >
              Contact
            </button>
          </nav>
        </div>{' '}
        {/* Auth buttons and theme toggle on the right */}
        <div className="flex items-center gap-2">
          <ThemeToggle />
          {/* Mobile menu button */}
          <button
            type="button"
            className="p-2 md:hidden"
            onClick={() => setIsMenuOpen(!isMenuOpen)}
            aria-label="Toggle menu"
          >
            {isMenuOpen ? (
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                strokeWidth={1.5}
                stroke="currentColor"
                className="h-6 w-6"
              >
                <title>Close menu</title>
                <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
              </svg>
            ) : (
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                strokeWidth={1.5}
                stroke="currentColor"
                className="h-6 w-6"
              >
                <title>Close menu</title>
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5"
                />
              </svg>
            )}
          </button>
        </div>
      </div>

      {/* Mobile navigation */}
      {isMenuOpen && (
        <div className="bg-background border-t py-4 md:hidden">
          <nav className="container flex flex-col space-y-3">
            <button
              type="button"
              onClick={scrollToTop}
              className="hover:text-accent px-4 py-2 text-left font-medium transition-colors"
            >
              Home
            </button>
            <button
              type="button"
              onClick={() => scrollToSection(NAV_SECTIONS.about)}
              className="hover:text-accent px-4 py-2 text-left font-medium transition-colors"
            >
              About
            </button>
            <button
              type="button"
              onClick={() => scrollToSection(NAV_SECTIONS.skills)}
              className="hover:text-accent px-4 py-2 text-left font-medium transition-colors"
            >
              Skills
            </button>
            <button
              type="button"
              onClick={() => scrollToSection(NAV_SECTIONS.projects)}
              className="hover:text-accent px-4 py-2 text-left font-medium transition-colors"
            >
              Projects
            </button>
            <button
              type="button"
              onClick={() => scrollToSection(NAV_SECTIONS.contact)}
              className="hover:text-accent px-4 py-2 text-left font-medium transition-colors"
            >
              Contact
            </button>
            <div className="flex justify-center px-4 pt-4">
              <ThemeToggle />
            </div>
          </nav>
        </div>
      )}
    </header>
  )
}
