export interface Project {
  name: string;
  subtitle?: string;
  role: string;
  year: string;
  stack: string[];
  blurb: string;
}

export const projects: Project[] = [
  {
    name: "OCR Payment Verification",
    subtitle: "“Trust the Card”",
    role: "Lead Dev · India",
    year: "2025",
    stack: ["NestJS", "OAuth 2.0", "OIDC"],
    blurb:
      "Led OCR-based card verification with OAuth 2.0 / OIDC, reducing fraudulent transactions by 85% in production. Owned API contracts, the threat model, and end-to-end QA.",
  },
  {
    name: "Vehicle Exchange Platform",
    role: "Full-Stack Engineer · UK",
    year: "2024",
    stack: ["MERN", "AWS S3", "JWT"],
    blurb:
      "Delivered a contactless license-plate-scan exchange flow with JWT auth and S3 storage, replacing manual paperwork at pilot sites; tuned the Webpack/Babel build to shrink bundle size.",
  },
  {
    name: "Biometric Verification System",
    subtitle: "“Trust the Customer”",
    role: "Lead Dev · UK",
    year: "2023",
    stack: ["MERN", "OAuth 2.0", "OIDC"],
    blurb:
      "Launched MERN-based biometric login with OAuth 2.0 / OIDC, cutting account-takeover fraud by 75% within the first release window.",
  },
  {
    name: "Express Exit Pass System",
    role: "Lead Dev · India",
    year: "2022",
    stack: ["Next.js", "Zustand", "NestJS"],
    blurb:
      "Built a QR-code self-service rental-return flow that removed the front-desk handoff and lifted customer satisfaction across pilot locations.",
  },
  {
    name: "Contactless PreCheck",
    role: "Developer · India",
    year: "2021",
    stack: ["React", "Spring Boot", "JWT"],
    blurb:
      "Shipped a contactless check-in flow on React + Spring Boot with JWT auth that cut counter wait time by 76%.",
  },
];
