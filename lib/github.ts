export interface Repo {
  name: string;
  description: string | null;
  url: string;
  language: string | null;
  stars: number;
  forks: number;
  updated: string;
}

const GITHUB_USER = "iamsg97";
const MAX_REPOS = 6;

interface GithubApiRepo {
  name: string;
  description: string | null;
  html_url: string;
  language: string | null;
  stargazers_count: number;
  forks_count: number;
  pushed_at: string;
  fork: boolean;
  archived: boolean;
}

/**
 * Fetches public, non-fork repos for the GitHub user, ranked by stars then
 * recency. Revalidated hourly (ISR) so the build stays static-friendly.
 * Returns [] on any failure so the section degrades gracefully.
 */
export async function getRepos(): Promise<Repo[]> {
  const headers: HeadersInit = {
    Accept: "application/vnd.github+json",
    "X-GitHub-Api-Version": "2022-11-28",
  };
  if (process.env.GITHUB_TOKEN) {
    headers.Authorization = `Bearer ${process.env.GITHUB_TOKEN}`;
  }

  try {
    const res = await fetch(
      `https://api.github.com/users/${GITHUB_USER}/repos?per_page=100&sort=pushed`,
      { headers, next: { revalidate: 3600 } },
    );
    if (!res.ok) return [];

    const data = (await res.json()) as GithubApiRepo[];
    if (!Array.isArray(data)) return [];

    return data
      .filter((r) => !r.fork && !r.archived)
      .sort((a, b) => {
        if (b.stargazers_count !== a.stargazers_count) {
          return b.stargazers_count - a.stargazers_count;
        }
        return new Date(b.pushed_at).getTime() - new Date(a.pushed_at).getTime();
      })
      .slice(0, MAX_REPOS)
      .map((r) => ({
        name: r.name,
        description: r.description,
        url: r.html_url,
        language: r.language,
        stars: r.stargazers_count,
        forks: r.forks_count,
        updated: r.pushed_at,
      }));
  } catch {
    return [];
  }
}
