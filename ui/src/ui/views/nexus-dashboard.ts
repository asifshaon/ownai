import { html, nothing } from "lit";
import { t } from "../../i18n/index.ts";
import { icons } from "../icons.ts";
import { formatCost, formatTokens } from "../format.ts";
import type {
  SessionsUsageResult,
  SkillStatusReport,
  CronJob,
  CronStatus,
} from "../types.ts";

export type NexusDashboardProps = {
  usageResult: SessionsUsageResult | null;
  skillsReport: SkillStatusReport | null;
  cronJobs: CronJob[];
  cronStatus: CronStatus | null;
  onNavigate: (tab: string) => void;
};

export function renderNexusDashboard(props: NexusDashboardProps) {
  const totals = props.usageResult?.totals;
  const totalCost = formatCost(totals?.totalCost);
  const totalTokens = formatTokens(totals?.totalTokens);
  
  const skills = props.skillsReport?.skills ?? [];
  const enabledSkills = skills.filter((s) => !s.disabled).length;
  
  return html`
    <style>
      .nexus-tower {
        display: flex;
        flex-direction: column;
        gap: 24px;
        padding: 24px;
        background: radial-gradient(circle at top right, rgba(0, 102, 255, 0.1), transparent),
                    radial-gradient(circle at bottom left, rgba(153, 0, 255, 0.1), transparent);
        border-radius: 16px;
        border: 1px solid rgba(255, 255, 255, 0.1);
        backdrop-filter: blur(10px);
        color: #fff;
        animation: nexus-fade-in 0.8s ease-out;
      }

      @keyframes nexus-fade-in {
        from { opacity: 0; transform: translateY(10px); }
        to { opacity: 1; transform: translateY(0); }
      }

      .nexus-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        padding-bottom: 20px;
      }

      .nexus-branding {
        display: flex;
        align-items: center;
        gap: 16px;
      }

      .nexus-sigil {
        width: 48px;
        height: 48px;
        background: linear-gradient(135deg, #00f2fe 0%, #4facfe 100%);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        box-shadow: 0 0 20px rgba(79, 172, 254, 0.5);
        animation: nexus-pulse 3s infinite ease-in-out;
      }

      @keyframes nexus-pulse {
        0%, 100% { transform: scale(1); box-shadow: 0 0 20px rgba(79, 172, 254, 0.5); }
        50% { transform: scale(1.05); box-shadow: 0 0 35px rgba(79, 172, 254, 0.8); }
      }

      .nexus-title {
        font-family: 'Outfit', sans-serif;
        font-size: 28px;
        font-weight: 700;
        letter-spacing: -0.5px;
        background: linear-gradient(to right, #fff, #a5b4fc);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
      }

      .nexus-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
        gap: 20px;
      }

      .nexus-card {
        background: rgba(255, 255, 255, 0.03);
        border: 1px solid rgba(255, 255, 255, 0.08);
        border-radius: 12px;
        padding: 20px;
        transition: all 0.3s ease;
        position: relative;
        overflow: hidden;
      }

      .nexus-card:hover {
        background: rgba(255, 255, 255, 0.05);
        border-color: rgba(255, 255, 255, 0.2);
        transform: translateY(-2px);
      }

      .nexus-card__label {
        font-size: 12px;
        text-transform: uppercase;
        letter-spacing: 1px;
        color: rgba(255, 255, 255, 0.5);
        margin-bottom: 8px;
        display: block;
      }

      .nexus-card__value {
        font-size: 32px;
        font-weight: 600;
        margin-bottom: 4px;
      }

      .nexus-card__status {
        display: flex;
        align-items: center;
        gap: 6px;
        font-size: 13px;
        color: #4facfe;
      }

      .nexus-agent-pulse {
        margin-top: 12px;
        padding-top: 12px;
        border-top: 1px solid rgba(255, 255, 255, 0.05);
      }

      .agent-row {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 8px 0;
      }

      .agent-tag {
        font-size: 11px;
        padding: 2px 8px;
        border-radius: 4px;
        background: rgba(79, 172, 254, 0.1);
        color: #4facfe;
        border: 1px solid rgba(79, 172, 254, 0.2);
      }

      .nexus-cta-bar {
        display: flex;
        gap: 12px;
        margin-top: 8px;
      }

      .nexus-btn {
        background: rgba(255, 255, 255, 0.05);
        border: 1px solid rgba(255, 255, 255, 0.1);
        color: #fff;
        padding: 10px 20px;
        border-radius: 8px;
        cursor: pointer;
        font-size: 14px;
        transition: all 0.2s;
        display: flex;
        align-items: center;
        gap: 8px;
      }

      .nexus-btn:hover {
        background: rgba(255, 255, 255, 0.1);
        border-color: #4facfe;
      }

      .nexus-btn.primary {
        background: linear-gradient(135deg, rgba(79, 172, 254, 0.2) 0%, rgba(0, 242, 254, 0.2) 100%);
        border-color: rgba(79, 172, 254, 0.5);
      }
    </style>

    <div class="nexus-tower">
      <div class="nexus-header">
        <div class="nexus-branding">
          <div class="nexus-sigil">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polygon points="12 2 2 7 12 12 22 7 12 2"></polygon>
              <polyline points="2 17 12 22 22 17"></polyline>
              <polyline points="2 12 12 17 22 12"></polyline>
            </svg>
          </div>
          <div>
            <div class="nexus-title">NEXUS CONTROL TOWER</div>
            <div style="font-size: 12px; color: rgba(255,255,255,0.4)">AGI Core • Infinite Layer • V3.1.2</div>
          </div>
        </div>
        <div class="nexus-cta-bar">
          <button class="nexus-btn primary" @click=${() => props.onNavigate("chat")}>
            ${icons.messageSquare} Open Mainframe
          </button>
        </div>
      </div>

      <div class="nexus-grid">
        <div class="nexus-card">
          <span class="nexus-card__label">System Energy</span>
          <div class="nexus-card__value">${totalCost}</div>
          <div class="nexus-card__status">
            ${icons.activity} ${totalTokens} tokens processed
          </div>
        </div>

        <div class="nexus-card">
          <span class="nexus-card__label">Neural Density</span>
          <div class="nexus-card__value">${enabledSkills} / ${skills.length}</div>
          <div class="nexus-card__status">
            ${icons.zap} Skills Online
          </div>
        </div>

        <div class="nexus-card" style="grid-column: span 1;">
          <span class="nexus-card__label">Active Modules</span>
          <div class="nexus-agent-pulse">
            <div class="agent-row">
              <span>The Architect</span>
              <span class="agent-tag">EVOLVING</span>
            </div>
            <div class="agent-row">
              <span>The Scribe</span>
              <span class="agent-tag">INDEXING</span>
            </div>
            <div class="agent-row">
              <span>The Black Team</span>
              <span class="agent-tag">TACTICAL</span>
            </div>
          </div>
        </div>
      </div>

      <div class="nexus-cta-bar">
        <button class="nexus-btn" @click=${() => props.onNavigate("overview")}>
          ${icons.barChart} Metrics
        </button>
        <button class="nexus-btn" @click=${() => props.onNavigate("agents")}>
          ${icons.folder} Personas
        </button>
        <button class="nexus-btn" @click=${() => props.onNavigate("config")}>
          ${icons.settings} Terminal
        </button>
      </div>
    </div>
  `;
}
