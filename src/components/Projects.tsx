import { SectionContainer } from './SectionContainer'
import { Button } from './ui/button'
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from './ui/card'

export default function Projects() {
  const projects = [
    {
      id: 1,
      title: 'Project One',
      description: 'A web application built with React and TypeScript',
      details:
        'This project demonstrates my ability to build modern, responsive web applications using React and TypeScript. Features include user authentication, data visualization, and real-time updates.',
      tags: ['React', 'TypeScript', 'Firebase', 'TailwindCSS'],
      imageUrl: 'https://placehold.co/600x400/e2e8f0/1e293b?text=Project+One',
      demoUrl: '#',
      repoUrl: '#',
    },
    {
      id: 2,
      title: 'Project Two',
      description: 'A full-stack application with Node.js backend',
      details:
        'This project showcases my backend skills using Node.js, Express, and MongoDB to create a robust API. The frontend uses React and communicates with the backend via RESTful endpoints.',
      tags: ['Node.js', 'Express', 'MongoDB', 'React', 'REST API'],
      imageUrl: 'https://placehold.co/600x400/e2e8f0/1e293b?text=Project+Two',
      demoUrl: '#',
      repoUrl: '#',
    },
    {
      id: 3,
      title: 'Project Three',
      description: 'A mobile-first UI/UX design',
      details:
        'This project highlights my design skills and attention to detail in creating beautiful user interfaces. The application features a responsive layout, animations, and accessibility considerations.',
      tags: ['UI/UX', 'Figma', 'React Native', 'Mobile Design'],
      imageUrl: 'https://placehold.co/600x400/e2e8f0/1e293b?text=Project+Three',
      demoUrl: '#',
      repoUrl: '#',
    },
  ]

  return (
    <section id="projects" className="py-16">
      <SectionContainer>
        <h2 className="mb-12 text-center text-3xl font-bold">Featured Projects</h2>

        <div className="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3">
          {projects.map(project => (
            <Card key={project.id} className="flex flex-col overflow-hidden">
              <div className="aspect-video overflow-hidden">
                <img
                  src={project.imageUrl}
                  alt={project.title}
                  className="h-full w-full object-cover transition-transform duration-300 hover:scale-105"
                />
              </div>
              <CardHeader>
                <CardTitle>{project.title}</CardTitle>
                <CardDescription>{project.description}</CardDescription>
              </CardHeader>
              <CardContent>
                <p className="mb-4">{project.details}</p>
                <div className="mt-3 flex flex-wrap gap-2">
                  {project.tags.map(tag => (
                    <span
                      key={tag}
                      className="bg-muted/60 rounded-md px-2 py-1 text-xs font-medium"
                    >
                      {tag}
                    </span>
                  ))}
                </div>
              </CardContent>
              <CardFooter className="mt-auto pt-4">
                <div className="flex gap-3">
                  <Button variant="outline" size="sm" asChild>
                    <a href={project.demoUrl} target="_blank" rel="noopener noreferrer">
                      Live Demo
                    </a>
                  </Button>
                  <Button variant="outline" size="sm" asChild>
                    <a href={project.repoUrl} target="_blank" rel="noopener noreferrer">
                      View Code
                    </a>
                  </Button>
                </div>
              </CardFooter>
            </Card>
          ))}
        </div>
      </SectionContainer>
    </section>
  )
}
