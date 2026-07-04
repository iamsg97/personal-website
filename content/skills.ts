export interface SkillGroup {
  label: string;
  items: string[];
}

export const skills: SkillGroup[] = [
  {
    label: "Languages",
    items: ["TypeScript", "JavaScript (ES6+)", "Java", "HTML5", "CSS3", "SQL"],
  },
  {
    label: "Frontend",
    items: ["React.js", "Next.js", "Redux", "Zustand", "React Query", "AEM", "Webpack", "Babel"],
  },
  {
    label: "Backend",
    items: [
      "Node.js",
      "Express.js",
      "NestJS",
      "Spring Boot",
      "REST",
      "Microservices",
      "Event-Driven",
    ],
  },
  {
    label: "Databases",
    items: ["MongoDB", "PostgreSQL", "Prisma ORM"],
  },
  {
    label: "Cloud & DevOps",
    items: [
      "AWS (EC2, S3, SQS/SNS, SSM)",
      "Docker",
      "Kubernetes",
      "Jenkins",
      "Bitbucket Pipelines",
    ],
  },
  {
    label: "AI / Agentic",
    items: [
      "AWS Kiro (spec-driven)",
      "Custom agents",
      "Steering docs",
      "Hooks",
      "MCP",
      "Context tuning",
    ],
  },
  {
    label: "Testing & Quality",
    items: ["Jest", "Vitest", "Mocha", "Cypress", "TDD", "Code Review"],
  },
  {
    label: "Security & Practices",
    items: [
      "OAuth 2.0",
      "OpenID Connect",
      "JWT",
      "RBAC",
      "SOLID",
      "Clean Architecture",
      "Agile/Scrum",
    ],
  },
];

export const certifications: string[] = [
  "AWS Certified Developer – Associate (DVA-C02)",
  "Claude AI Fluency: Framework & Foundations — Anthropic",
  "Claude 101 — Anthropic",
];
