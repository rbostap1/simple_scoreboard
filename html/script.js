let currentPage = 1;
let allPlayers = [];
let maxPlayers = 32;
let currentPlayerId = null;
let highlightEnabled = true;
let highlightColor = "#E56B1F";
let logoEnabled = true;
let colors = {};

const playersPerPage = 12;

function hexToRgb(hex) {
    const normalized = `${hex || ""}`.trim();
    const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(normalized);
    if (!result) return null;
    return {
        r: parseInt(result[1], 16),
        g: parseInt(result[2], 16),
        b: parseInt(result[3], 16)
    };
}

function rgbaFromHex(hex, alpha) {
    const rgb = hexToRgb(hex);
    if (!rgb) return null;
    return `rgba(${rgb.r}, ${rgb.g}, ${rgb.b}, ${alpha})`;
}

function safeDepartment(dept) {
    const fallback = {
        key: "civ",
        label: "Civilian",
        shortLabel: "CIV",
        color: "#B8A168",
        icon: "user"
    };

    if (!dept || typeof dept !== "object") {
        return fallback;
    }

    return {
        key: dept.key || fallback.key,
        label: dept.label || fallback.label,
        shortLabel: dept.shortLabel || dept.label || fallback.shortLabel,
        color: dept.color || fallback.color,
        icon: dept.icon || fallback.icon
    };
}

function iconForDepartment(icon) {
    const map = {
        shield: "S",
        plus: "+",
        flame: "F",
        user: "U",
        dot: "o"
    };

    return map[icon] || "o";
}

function applyColorVariables(configColors) {
    const root = document.documentElement;
    colors = configColors || {};

    const setColor = (name, value, fallback) => {
        const target = value || fallback;
        root.style.setProperty(`--${name}`, target);
        const rgb = hexToRgb(target);
        if (rgb) {
            root.style.setProperty(`--${name}-rgb`, `${rgb.r} ${rgb.g} ${rgb.b}`);
        }
    };

    setColor("accent", colors.primary, "#E56B1F");
    setColor("accent-2", colors.secondary, "#3A86FF");
    setColor("text-main", colors.textWhite, "#FAF6E9");
    setColor("text-muted", colors.textSecondary, "#C3B9A8");

    root.style.setProperty("--panel", colors.cardBg || "rgba(11, 16, 26, 0.78)");
    root.style.setProperty("--panel-strong", colors.backgroundDark || "rgba(16, 22, 36, 0.92)");
    root.style.setProperty("--bg-0", colors.background || "#070B12");
    root.style.setProperty("--bg-1", colors.backgroundDark || "#0D1320");
    root.style.setProperty("--bg-2", colors.cardBg || "#111A2B");

    const accent = colors.primary || "#E56B1F";
    const accentDark = colors.primaryDark || "#A64619";
    const accent2 = colors.secondary || "#3A86FF";

    root.style.setProperty("--glow", rgbaFromHex(accent, 0.24) || "rgba(229, 107, 31, 0.24)");
    root.style.setProperty("--glow-2", rgbaFromHex(accent2, 0.18) || "rgba(58, 134, 255, 0.18)");
    root.style.setProperty("--shadow", colors.shadowColor || "rgba(0, 0, 0, 0.56)");
    root.style.setProperty("--shadow-strong", colors.shadowStrong || "rgba(0, 0, 0, 0.72)");

    root.style.setProperty("--primary", accent);
    root.style.setProperty("--primary-rgb", hexToRgb(accent) ? `${hexToRgb(accent).r} ${hexToRgb(accent).g} ${hexToRgb(accent).b}` : "229 107 31");
    root.style.setProperty("--primary-dark", accentDark);
    root.style.setProperty("--primary-dark-rgb", hexToRgb(accentDark) ? `${hexToRgb(accentDark).r} ${hexToRgb(accentDark).g} ${hexToRgb(accentDark).b}` : "166 70 25");
    root.style.setProperty("--secondary", accent2);
    root.style.setProperty("--text-white", colors.textWhite || "#FAF6E9");
    root.style.setProperty("--text-accent", colors.textAccent || "#FFC88E");
    root.style.setProperty("--text-secondary", colors.textSecondary || "#C3B9A8");
    root.style.setProperty("--background", colors.background || "rgba(9, 13, 20, 0.94)");
    root.style.setProperty("--background-dark", colors.backgroundDark || "rgba(5, 8, 13, 0.98)");
    root.style.setProperty("--card-bg", colors.cardBg || "rgba(18, 24, 35, 0.82)");
}

function renderDepartmentSummary() {
    const summaryEl = document.getElementById("departmentSummary");
    const departmentCountEl = document.getElementById("departmentCount");
    summaryEl.innerHTML = "";

    if (!Array.isArray(allPlayers) || allPlayers.length === 0) {
        if (departmentCountEl) {
            departmentCountEl.textContent = "0";
        }
        return;
    }

    const totals = {};
    allPlayers.forEach((player) => {
        const dept = safeDepartment(player.department);
        const key = dept.key;
        if (!totals[key]) {
            totals[key] = {
                dept,
                count: 0
            };
        }
        totals[key].count += 1;
    });

    const entries = Object.values(totals).sort((a, b) => b.count - a.count);

    entries.forEach((entry) => {
        const rgb = hexToRgb(entry.dept.color) || { r: 138, g: 143, b: 152 };
        const pill = document.createElement("div");
        pill.className = "dept-pill";
        pill.style.setProperty("--dept-rgb", `${rgb.r} ${rgb.g} ${rgb.b}`);
        pill.textContent = `${entry.dept.shortLabel}: ${entry.count}`;
        summaryEl.appendChild(pill);
    });

    if (departmentCountEl) {
        departmentCountEl.textContent = `${entries.length}`;
    }
}

function renderPlayerPage() {
    const list = document.getElementById("playerlist");
    list.innerHTML = "";

    if (!allPlayers || allPlayers.length === 0) {
        list.innerHTML = "<div class='empty-state'>No players online</div>";
        document.getElementById("pagination").style.display = "none";
        return;
    }

    const startIdx = (currentPage - 1) * playersPerPage;
    const endIdx = startIdx + playersPerPage;
    const pagePlayers = allPlayers.slice(startIdx, endIdx);

    pagePlayers.forEach((player, index) => {
        const card = document.createElement("div");
        card.className = "player-card";
        card.style.setProperty("--card-delay", `${index * 35}ms`);

        if (highlightEnabled && player && player.id === currentPlayerId) {
            card.classList.add("current-player");
        }

        const playerId = player && player.id ? player.id : "?";
        const playerName = player && player.name ? player.name : "Unknown";
        const dept = safeDepartment(player.department);
        const rgb = hexToRgb(dept.color) || { r: 138, g: 143, b: 152 };

        card.innerHTML = `
            <div class="player-top">
                <div class="player-index">#${startIdx + index + 1}</div>
                <div class="player-id">ID ${playerId}</div>
            </div>
            <div class="player-name">${playerName}</div>
            <div class="dept-badge" style="--dept-rgb:${rgb.r} ${rgb.g} ${rgb.b}">
                <span class="dept-dot"></span>
                <span>${iconForDepartment(dept.icon)} ${dept.shortLabel}</span>
            </div>
        `;

        list.appendChild(card);
    });

    const totalPages = Math.max(1, Math.ceil(allPlayers.length / playersPerPage));
    document.getElementById("prevPage").disabled = currentPage === 1;
    document.getElementById("nextPage").disabled = currentPage === totalPages;
    document.getElementById("pageIndicator").textContent = `Page ${currentPage} / ${totalPages}`;
    document.getElementById("pagination").style.display = totalPages > 1 ? "flex" : "none";
}

document.getElementById("prevPage").addEventListener("click", () => {
    if (currentPage > 1) {
        currentPage -= 1;
        renderPlayerPage();
    }
});

document.getElementById("nextPage").addEventListener("click", () => {
    const totalPages = Math.max(1, Math.ceil(allPlayers.length / playersPerPage));
    if (currentPage < totalPages) {
        currentPage += 1;
        renderPlayerPage();
    }
});

window.addEventListener("message", (event) => {
    const data = event.data;

    if (data.action === "toggle") {
        const sb = document.getElementById("scoreboard");
        const isOpen = !!data.show;
        sb.style.display = isOpen ? "block" : "none";
        document.body.classList.toggle("scoreboard-open", isOpen);
    }

    if (data.action === "config") {
        const nameEl = document.getElementById("servername");
        const logoEl = document.getElementById("logo");
        const logoFallback = document.getElementById("logoFallback");
        const root = document.documentElement;

        if (data.serverName) {
            nameEl.textContent = data.serverName;
        }

        if (data.logoEnabled !== undefined) {
            logoEnabled = !!data.logoEnabled;
        }

        if (logoEnabled && data.logo && data.logo !== "") {
            logoEl.src = data.logo;
            logoEl.style.display = "block";
            logoFallback.style.display = "none";
        } else {
            logoEl.style.display = "none";
            logoFallback.style.display = "grid";
        }

        if (data.maxPlayers) {
            maxPlayers = data.maxPlayers;
        }

        if (data.highlightEnabled !== undefined) {
            highlightEnabled = !!data.highlightEnabled;
        }

        if (data.highlightColor) {
            highlightColor = data.highlightColor;
            root.style.setProperty("--highlight-color", highlightColor);
            const rgb = hexToRgb(highlightColor);
            if (rgb) {
                root.style.setProperty("--highlight-color-rgb", `${rgb.r} ${rgb.g} ${rgb.b}`);
            }
        }

        if (data.colors && typeof data.colors === "object") {
            applyColorVariables(data.colors);
        }
    }

    if (data.action === "update") {
        if (!Array.isArray(data.players)) {
            return;
        }

        allPlayers = data.players;
        currentPage = 1;

        if (data.currentPlayerId !== undefined) {
            currentPlayerId = data.currentPlayerId;
        }

        renderDepartmentSummary();
        renderPlayerPage();

        const playerCount = document.getElementById("playercount");
        const playerCountMirror = document.getElementById("playercountMirror");
        const playerCountText = `${allPlayers.length} / ${maxPlayers}`;
        playerCount.textContent = playerCountText;
        if (playerCountMirror) {
            playerCountMirror.textContent = playerCountText;
        }
    }
});
