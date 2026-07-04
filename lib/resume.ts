import { readFileSync } from "node:fs";
import { join } from "node:path";
import matter from "gray-matter";
import { z } from "zod";

// Schema for the resume.mdx frontmatter. Editing the MDX and breaking the shape
// surfaces a clear error at build time rather than a silent broken section.
const JobSchema = z.object({
  company: z.string(),
  role: z.string(),
  period: z.string(),
  location: z.string(),
  note: z.string().optional(),
  highlights: z.array(z.string()),
});

const ProjectSchema = z.object({
  name: z.string(),
  subtitle: z.string().optional(),
  role: z.string(),
  year: z.string(),
  stack: z.array(z.string()),
  blurb: z.string(),
});

const SkillGroupSchema = z.object({
  label: z.string(),
  items: z.array(z.string()),
});

const CertificationSchema = z.object({
  name: z.string(),
  // done: true → earned (green ✓); false → in progress (yellow clock).
  done: z.boolean(),
});

const ResumeSchema = z.object({
  experience: z.array(JobSchema),
  projects: z.array(ProjectSchema),
  skills: z.array(SkillGroupSchema),
  certifications: z.array(CertificationSchema),
});

export type Job = z.infer<typeof JobSchema>;
export type Project = z.infer<typeof ProjectSchema>;
export type SkillGroup = z.infer<typeof SkillGroupSchema>;
export type Certification = z.infer<typeof CertificationSchema>;
export type Resume = z.infer<typeof ResumeSchema>;

let cached: Resume | null = null;

/** Parses content/resume.mdx once and returns the validated resume data. */
export function getResume(): Resume {
  if (cached) return cached;
  const file = readFileSync(join(process.cwd(), "content/resume.mdx"), "utf8");
  const { data } = matter(file);
  cached = ResumeSchema.parse(data);
  return cached;
}
