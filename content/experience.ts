export interface Job {
  company: string;
  role: string;
  period: string;
  location: string;
  note?: string;
  highlights: string[];
}

export const experience: Job[] = [
  {
    company: "LTIMindtree",
    role: "Senior Software Engineer",
    period: "Mar 2021 — Present",
    location: "Bangalore · Bracknell (UK) · Kolkata",
    note: "Tier-1 IT services MNC",
    highlights: [
      "Shipped React/Next.js + Node.js platforms serving 50,000+ daily users across UK and India deployments; owned delivery end-to-end from scoping to production rollout.",
      "Re-engineered REST APIs on Express.js and NestJS, cutting average API response time by 60% and removing peak-hour timeouts without added infrastructure cost.",
      "Led an AngularJS → Next.js migration for a customer-facing portal, lifting UI performance by 35% and enabling SSR for faster first-load and SEO gains.",
      "Built and shipped two fraud-prevention products (OCR card + biometric flows), cutting fraudulent transactions by 75–85% and protecting customer payments at scale.",
      "Designed event-driven backends on AWS SQS/SNS using SOLID and clean-architecture patterns, decoupling downstream services and improving fault isolation.",
      "Mentored 10 junior engineers; ran Agile ceremonies and stakeholder alignment across UK onsite and India offshore teams.",
      "Hardened CI/CD on Bitbucket Pipelines + Jenkins with Jest/Vitest gates for safer releases.",
    ],
  },
];
