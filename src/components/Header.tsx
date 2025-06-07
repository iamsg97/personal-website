import { Link } from '@tanstack/react-router'
import { useEffect, useState } from 'react'
import { ThemeToggle } from './ThemeToggle'
import { Button } from './ui/button'

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

  return (
    <header
      className={`bg-background sticky top-0 z-40 border-b ${scrolled ? 'shadow-sm' : ''} transition-shadow`}
    >
      <div className="container flex h-16 items-center justify-between py-4">
        {/* Logo on the left */}
        <div>
          <Link to="/" className="text-xl font-bold">
            My Portfolio
          </Link>
        </div>
        {/* Navigation centered - desktop */}
        <div className="flex flex-grow justify-center">
          {' '}
          <nav className="hidden items-center gap-6 text-sm md:flex">
            <Link to="/" className="hover:text-accent font-medium transition-colors">
              Home
            </Link>
            <button
              type="button"
              onClick={() => scrollToSection('about')}
              className="hover:text-accent font-medium transition-colors"
            >
              About
            </button>
            <button
              type="button"
              onClick={() => scrollToSection('skills')}
              className="hover:text-accent font-medium transition-colors"
            >
              Skills
            </button>
            <button
              type="button"
              onClick={() => scrollToSection('projects')}
              className="hover:text-accent font-medium transition-colors"
            >
              Projects
            </button>
            <button
              type="button"
              onClick={() => scrollToSection('contact')}
              className="hover:text-accent font-medium transition-colors"
            >
              Contact
            </button>
          </nav>
        </div>{' '}
        {/* Auth buttons and theme toggle on the right */}
        <div className="flex items-center gap-2">
          <ThemeToggle />
          <div className="hidden md:block">
            <Button variant="outline" size="sm">
              Sign In
            </Button>
            <Button size="sm" className="ml-2">
              Sign Up
            </Button>
          </div>{' '}
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
            <Link
              to="/"
              className="hover:text-accent px-4 py-2 font-medium transition-colors"
              onClick={handleNavClick}
            >
              Home
            </Link>
            <button
              type="button"
              onClick={() => scrollToSection('about')}
              className="hover:text-accent px-4 py-2 text-left font-medium transition-colors"
            >
              About
            </button>
            <button
              type="button"
              onClick={() => scrollToSection('skills')}
              className="hover:text-accent px-4 py-2 text-left font-medium transition-colors"
            >
              Skills
            </button>
            <button
              type="button"
              onClick={() => scrollToSection('projects')}
              className="hover:text-accent px-4 py-2 text-left font-medium transition-colors"
            >
              Projects
            </button>
            <button
              type="button"
              onClick={() => scrollToSection('contact')}
              className="hover:text-accent px-4 py-2 text-left font-medium transition-colors"
            >
              Contact
            </button>
            <div className="flex items-center justify-between gap-2 px-4 pt-4">
              <ThemeToggle />
              <div className="flex flex-1 gap-2">
                <Button variant="outline" size="sm" className="w-full">
                  Sign In
                </Button>
                <Button size="sm" className="w-full">
                  Sign Up
                </Button>
              </div>
            </div>
          </nav>
        </div>
      )}
    </header>
  )
}
