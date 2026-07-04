export interface Social {
  label: string;
  handle: string;
  href: string;
}

export const profile = {
  name: "Suvadeep Ghoshal",
  role: "Senior Software Engineer",
  handle: "suvadeep",
  host: "web",
  tagline:
    "Senior Software Engineer shipping production MERN & Next.js platforms for 50,000+ daily users — with a bias toward security, performance, and clean architecture.",
  status: "5+ yrs · React · Node.js · TypeScript · AWS",
  location: "Konnagar, West Bengal, India",
  email: "ghoshalsuvadeep594@gmail.com",
  resumeUrl: "/Suvadeep_Ghoshal_SSE_Resume.pdf",

  about: [
    "I'm a Senior Software Engineer with 5+ years at LTIMindtree — including two years onsite in the UK — shipping production MERN and Next.js platforms that serve 50,000+ daily users. I work across the stack: React/Next.js on the front, Node.js/NestJS and event-driven AWS on the back, with a bias toward security, performance, and clean architecture.",
    "Lately I've been deep in AI-augmented and agentic development — Claude-powered workflows, tool orchestration, and spec-driven delivery — and in hardening cloud systems for regulated, fraud-sensitive domains. I also mentor junior engineers and enjoy the parts of the job that aren't code: scoping, threat-modelling, and keeping teams aligned across timezones.",
  ],

  socials: [
    { label: "github", handle: "iamsg97", href: "https://github.com/iamsg97" },
    {
      label: "linkedin",
      handle: "suvadeepghoshal",
      href: "https://www.linkedin.com/in/suvadeepghoshal/",
    },
    { label: "x", handle: "ghoshalsuvadeep", href: "https://x.com/ghoshalsuvadeep" },
  ] satisfies Social[],
} as const;

export type Profile = typeof profile;

// Aspirations support inline links: a plain string, an internal anchor link
// (href starting with "#"), or an external link (external: true).
export type AspirationPart = string | { text: string; href: string; external?: boolean };
export interface Aspiration {
  parts: AspirationPart[];
}

export const aspirations: Aspiration[] = [
  {
    parts: [
      "Grow into technical leadership — owning architecture and mentoring engineers, not just shipping features.",
    ],
  },
  {
    parts: [
      "Build AI-native, agentic systems — MCP, AI-automated workflows, LangChain & LangGraph — that make engineering teams meaningfully faster.",
    ],
  },
  {
    parts: [
      "Go deeper on secure, event-driven cloud platforms — and on the systems-engineering layer beneath them: Kubernetes internals (control plane, data plane), ",
      {
        text: "learning K8s the hard way",
        href: "https://github.com/kelseyhightower/kubernetes-the-hard-way",
        external: true,
      },
      ".",
    ],
  },
  {
    parts: [
      { text: "Keep learning in the open ↓", href: "#git-remote" },
      " — dotfiles, side projects, and whatever I'm hacking on next.",
    ],
  },
];
