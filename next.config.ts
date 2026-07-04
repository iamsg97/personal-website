import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // The home page reads content/resume.mdx via fs. Because it revalidates (ISR),
  // that read can run at runtime, so bundle the file with the route's function.
  outputFileTracingIncludes: {
    "/": ["./content/resume.mdx"],
  },
};

export default nextConfig;
