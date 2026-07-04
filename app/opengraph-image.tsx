import { ImageResponse } from "next/og";
import { profile } from "@/content/profile";

export const size = { width: 1200, height: 630 };
export const contentType = "image/png";
export const alt = `${profile.name} — ${profile.role}`;

// Terminal-window social card.
export default function OpengraphImage() {
  return new ImageResponse(
    <div
      style={{
        width: "100%",
        height: "100%",
        display: "flex",
        flexDirection: "column",
        background: "#0d1117",
        fontFamily: "monospace",
        padding: 56,
      }}
    >
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          flex: 1,
          border: "1px solid #30363d",
          background: "#161b22",
        }}
      >
        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: 12,
            padding: "16px 22px",
            borderBottom: "1px solid #30363d",
            background: "#010409",
            color: "#8b949e",
            fontSize: 22,
          }}
        >
          <div style={{ display: "flex", gap: 10 }}>
            <div style={{ width: 16, height: 16, borderRadius: 8, background: "#30363d" }} />
            <div style={{ width: 16, height: 16, borderRadius: 8, background: "#30363d" }} />
            <div style={{ width: 16, height: 16, borderRadius: 8, background: "#30363d" }} />
          </div>
          <div>{`${profile.handle}@${profile.host}: ~`}</div>
        </div>

        <div style={{ display: "flex", flexDirection: "column", padding: "40px 48px", gap: 18 }}>
          <div style={{ color: "#8b949e", fontSize: 28 }}>$ whoami</div>
          <div style={{ color: "#e6edf3", fontSize: 76, fontWeight: 700 }}>{profile.name}</div>
          <div style={{ color: "#3fb950", fontSize: 34 }}>{profile.role}</div>
          <div style={{ color: "#8b949e", fontSize: 26 }}>{profile.status}</div>
          <div style={{ display: "flex", alignItems: "center", color: "#8b949e", fontSize: 28 }}>
            ${" "}
            <span
              style={{
                display: "block",
                width: 16,
                height: 30,
                marginLeft: 10,
                background: "#3fb950",
              }}
            />
          </div>
        </div>
      </div>
    </div>,
    size,
  );
}
