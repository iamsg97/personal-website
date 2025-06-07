// filepath: /home/iamsg/codebase/playground/iamsg/src/components/Footer.tsx

export default function Footer() {
  const currentYear = new Date().getFullYear()

  return (
    <footer className="bg-muted/50 text-foreground border-t p-6">
      <div className="container mx-auto">
        <div className="flex flex-col items-center justify-between md:flex-row">
          <div className="mb-4 md:mb-0">
            <p className="text-sm">© {currentYear} Suvadeep Ghoshal. All rights reserved.</p>
          </div>
          <div className="flex space-x-4">
            <a
              href="https://github.com/iamsg97"
              target="_blank"
              rel="noopener noreferrer"
              className="hover:text-accent transition-colors"
            >
              GitHub
            </a>
            <a
              href="https://www.linkedin.com/in/suvadeepghoshal"
              target="_blank"
              rel="noopener noreferrer"
              className="hover:text-accent transition-colors"
            >
              LinkedIn
            </a>
            <a
              href="https://x.com/ghoshalsuvadeep"
              target="_blank"
              rel="noopener noreferrer"
              className="hover:text-accent transition-colors"
            >
              Twitter
            </a>
          </div>
        </div>
      </div>
    </footer>
  )
}
