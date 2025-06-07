import { Card, CardContent } from './ui/card'

export default function About() {
  return (
    <section id="about" className="py-16">
      <div className="container">
        <h2 className="mb-12 text-center text-3xl font-bold">About Me</h2>

        <div className="grid grid-cols-1 gap-8 lg:grid-cols-3">
          <div className="lg:col-span-1">
            <div className="bg-muted/30 flex aspect-square items-center justify-center rounded-lg">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                strokeWidth={1.5}
                stroke="currentColor"
                className="text-muted-foreground/60 h-1/2 w-1/2"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  d="M15.75 6a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0ZM4.501 20.118a7.5 7.5 0 0 1 14.998 0A17.933 17.933 0 0 1 12 21.75c-2.676 0-5.216-.584-7.499-1.632Z"
                />
              </svg>
            </div>
          </div>

          <div className="lg:col-span-2">
            <Card>
              <CardContent className="pt-6">
                <h3 className="mb-4 text-2xl font-semibold">Full Stack Developer</h3>
                <p className="mb-4 text-lg">
                  I'm a passionate Full Stack Developer with expertise in modern web technologies.
                  With a strong foundation in both frontend and backend development, I create
                  scalable, efficient, and user-friendly applications.
                </p>
                <p className="mb-4">
                  My journey in software development began over 5 years ago, and I've since worked
                  on various projects ranging from small business websites to complex enterprise
                  applications. I'm always eager to learn new technologies and methodologies to
                  improve my craft.
                </p>
                <p>
                  When I'm not coding, you can find me hiking, reading about new tech trends, or
                  contributing to open-source projects. I believe in continuous learning and sharing
                  knowledge with the developer community.
                </p>

                <div className="mt-6 grid grid-cols-1 gap-4 sm:grid-cols-2">
                  <div>
                    <h4 className="mb-2 font-medium">Education</h4>
                    <ul className="space-y-1">
                      <li>BSc in Computer Science, Example University (2018-2022)</li>
                      <li>Full Stack Web Development Bootcamp (2023)</li>
                    </ul>
                  </div>
                  <div>
                    <h4 className="mb-2 font-medium">Experience</h4>
                    <ul className="space-y-1">
                      <li>Full Stack Developer at Tech Solutions Inc. (2022-Present)</li>
                      <li>Frontend Developer Intern at Web Innovations (2021)</li>
                    </ul>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      </div>
    </section>
  )
}
