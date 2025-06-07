import { Card, CardContent } from './ui/card'

export default function Skills() {
  const skillCategories = [
    {
      name: 'Frontend',
      skills: ['React', 'TypeScript', 'Next.js', 'TailwindCSS', 'HTML/CSS', 'JavaScript (ES6+)'],
    },
    {
      name: 'Backend',
      skills: ['Node.js', 'Express', 'NestJS', 'Python', 'RESTful APIs', 'GraphQL'],
    },
    {
      name: 'Database',
      skills: ['MongoDB', 'PostgreSQL', 'MySQL', 'Redis', 'Prisma', 'Mongoose'],
    },
    {
      name: 'DevOps & Tools',
      skills: ['Git', 'Docker', 'CI/CD', 'AWS', 'Linux', 'Jest/Testing'],
    },
  ]

  return (
    <section id="skills" className="bg-muted/30 py-16">
      <div className="container px-4 sm:px-6 lg:px-8">
        <h2 className="mb-12 text-center text-3xl font-bold">Skills & Technologies</h2>

        <div className="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-4">
          {skillCategories.map(category => (
            <Card key={category.name} className="overflow-hidden">
              <div className="bg-accent/10 p-4">
                <h3 className="text-xl font-semibold">{category.name}</h3>
              </div>
              <CardContent className="pt-6">
                <ul className="space-y-2">
                  {category.skills.map(skill => (
                    <li key={skill} className="flex items-center gap-2">
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        viewBox="0 0 20 20"
                        fill="currentColor"
                        className="text-accent h-5 w-5"
                      >
                        <path
                          fillRule="evenodd"
                          d="M10 18a8 8 0 1 0 0-16 8 8 0 0 0 0 16Zm3.857-9.809a.75.75 0 0 0-1.214-.882l-3.483 4.79-1.88-1.88a.75.75 0 1 0-1.06 1.061l2.5 2.5a.75.75 0 0 0 1.137-.089l4-5.5Z"
                          clipRule="evenodd"
                        />
                      </svg>
                      {skill}
                    </li>
                  ))}
                </ul>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    </section>
  )
}
