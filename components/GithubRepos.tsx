import { getRepos } from "@/lib/github";
import styles from "./GithubRepos.module.css";

function formatDate(iso: string): string {
  return new Date(iso).toLocaleDateString("en-GB", {
    year: "numeric",
    month: "short",
  });
}

export async function GithubRepos() {
  const repos = await getRepos();

  if (repos.length === 0) {
    return (
      <p className={styles.empty}>
        <span className={styles.dollar}>$</span> repos unavailable — see{" "}
        <a href="https://github.com/iamsg97" target="_blank" rel="noreferrer noopener">
          github.com/iamsg97
        </a>
      </p>
    );
  }

  return (
    <ul className={styles.list}>
      {repos.map((repo) => (
        <li key={repo.name}>
          <a className={styles.repo} href={repo.url} target="_blank" rel="noreferrer noopener">
            <div className={styles.head}>
              <span className={styles.name}>{repo.name}</span>
              <span className={styles.stats}>
                {repo.language ? <span className={styles.lang}>{repo.language}</span> : null}
                <span title="stars">★ {repo.stars}</span>
                <span title="forks">⑂ {repo.forks}</span>
              </span>
            </div>
            {repo.description ? <p className={styles.desc}>{repo.description}</p> : null}
            <p className={styles.updated}>updated {formatDate(repo.updated)}</p>
          </a>
        </li>
      ))}
    </ul>
  );
}
