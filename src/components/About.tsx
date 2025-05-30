import { Card, CardContent } from './ui/card'

export default function About() {
  return (
    <section id="about" className="py-16">
      <div className="container">
        <h2 className="text-3xl font-bold text-center mb-12">About Me</h2>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          <div className="lg:col-span-1">
            <div className="aspect-square bg-muted/30 rounded-lg flex items-center justify-center">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                strokeWidth={1.5}
                stroke="currentColor"
                className="w-1/2 h-1/2 text-muted-foreground/60"
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
                <h3 className="text-2xl font-semibold mb-4">
                  Full Stack Developer
                </h3>
                <p className="text-lg mb-4">
                  I'm a passionate Full Stack Developer with expertise in modern
                  web technologies. With a strong foundation in both frontend
                  and backend development, I create scalable, efficient, and
                  user-friendly applications.
                </p>
                <p className="mb-4">
                  My journey in software development began over 5 years ago, and
                  I've since worked on various projects ranging from small
                  business websites to complex enterprise applications. I'm
                  always eager to learn new technologies and methodologies to
                  improve my craft.
                </p>
                <p>
                  When I'm not coding, you can find me hiking, reading about new
                  tech trends, or contributing to open-source projects. I
                  believe in continuous learning and sharing knowledge with the
                  developer community.
                </p>

                <div className="mt-6 grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div>
                    <h4 className="font-medium mb-2">Education</h4>
                    <ul className="space-y-1">
                      <li>
                        BSc in Computer Science, Example University (2018-2022)
                      </li>
                      <li>Full Stack Web Development Bootcamp (2023)</li>
                    </ul>
                  </div>
                  <div>
                    <h4 className="font-medium mb-2">Experience</h4>
                    <ul className="space-y-1">
                      <li>
                        Full Stack Developer at Tech Solutions Inc.
                        (2022-Present)
                      </li>
                      <li>
                        Frontend Developer Intern at Web Innovations (2021)
                      </li>
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
