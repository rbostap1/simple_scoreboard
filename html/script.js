let currentPage = 1;
let allPlayers = [];
let maxPlayers = 32;
let currentPlayerId = null;
let highlightEnabled = true;
let highlightColor = "#6495FF";
let logoEnabled = true;
let colors = {};
let hudEnabled = false;
const playersPerPage = 12;

const hudEl = document.getElementById("playerhud");
const hudIdEl = document.getElementById("playerhud-id");
const hudNameEl = document.getElementById("playerhud-name");
const hudPlayersEl = document.getElementById("playerhud-players");

// Convert hex color to RGB values
function hexToRgb(hex) {
    const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result ? {
        r: parseInt(result[1], 16),
        g: parseInt(result[2], 16),
        b: parseInt(result[3], 16)
    } : null;
}

function renderPlayerPage() {
    const list = document.getElementById("playerlist");
    list.innerHTML = "";

    if (!allPlayers || allPlayers.length === 0) {
        list.innerHTML = "<div class='empty-state'>No players online</div>";
        return;
    }

    const startIdx = (currentPage - 1) * playersPerPage;
    const endIdx = startIdx + playersPerPage;
    const pagePlayers = allPlayers.slice(startIdx, endIdx);

    pagePlayers.forEach((player, index) => {
        const card = document.createElement("div");
        card.className = "player-card";
        
        // Apply highlight to current player if enabled
        if (highlightEnabled && player && player.id === currentPlayerId) {
            card.classList.add("current-player");
            card.style.setProperty("--highlight-color", highlightColor);
        }
        
        const playerId = player && player.id ? player.id : "?";
        const playerName = player && player.name ? player.name : "Unknown";
        
        card.innerHTML = `
            <div class="player-card-header">
                <div class="player-rank">${startIdx + index + 1}</div>
                <div class="player-badge">${playerId}</div>
            </div>
            <div class="player-card-body">
                <div class="player-name">${playerName}</div>
            </div>
        `;
        list.appendChild(card);
    });

    // Update pagination buttons
    const totalPages = Math.ceil(allPlayers.length / playersPerPage);
    document.getElementById("prevPage").disabled = currentPage === 1;
    document.getElementById("nextPage").disabled = currentPage === totalPages;
    document.getElementById("pageIndicator").textContent = `Page ${currentPage} / ${totalPages}`;

    // Hide pagination if only one page
    const pagination = document.getElementById("pagination");
    pagination.style.display = totalPages > 1 ? "flex" : "none";
}

// Pagination button handlers
document.getElementById("prevPage").addEventListener("click", () => {
    if (currentPage > 1) {
        currentPage--;
        renderPlayerPage();
    }
});

document.getElementById("nextPage").addEventListener("click", () => {
    const totalPages = Math.ceil(allPlayers.length / playersPerPage);
    if (currentPage < totalPages) {
        currentPage++;
        renderPlayerPage();
    }
});

window.addEventListener("message", function (event) {
    const data = event.data;

    if (data.action === "toggle") {
        const sb = document.getElementById("scoreboard");
        sb.style.display = data.show ? "block" : "none";
    }

    if (data.action === "config") {
        const nameEl = document.getElementById("servername");
        const logoEl = document.getElementById("logo");
        const headerFirstChild = document.getElementById("header").querySelector("div:first-child");
        const root = document.documentElement;

        if (data.serverName) {
            nameEl.textContent = data.serverName;
        }

        // Store logo enabled setting
        if (data.logoEnabled !== undefined) {
            logoEnabled = data.logoEnabled;
        }

        // Handle logo display and spacing
        if (logoEnabled && data.logo && data.logo !== "") {
            logoEl.src = data.logo;
            logoEl.style.display = "block";
            headerFirstChild.classList.remove("no-logo");
        } else {
            logoEl.style.display = "none";
            headerFirstChild.classList.add("no-logo");
        }

        // Store max players from config
        if (data.maxPlayers) {
            maxPlayers = data.maxPlayers;
        }
        
        // Store highlight settings from config
        if (data.highlightEnabled !== undefined) {
            highlightEnabled = data.highlightEnabled;
        }
        
        if (data.highlightColor) {
            highlightColor = data.highlightColor;
            // Apply highlight color as CSS variable
            root.style.setProperty("--highlight-color", highlightColor);
            // Convert and set RGB values
            const rgb = hexToRgb(highlightColor);
            if (rgb) {
                root.style.setProperty("--highlight-color-rgb", `${rgb.r} ${rgb.g} ${rgb.b}`);
            }
        }
        
        // Store and apply colors from config
        if (data.colors && Object.keys(data.colors).length > 0) {
            colors = data.colors;
            
            // Helper function to set color and RGB variables
            const setColorVar = (varName, colorValue, defaultValue) => {
                const color = colorValue || defaultValue;
                root.style.setProperty(`--${varName}`, color);
                const rgb = hexToRgb(color);
                if (rgb) {
                    root.style.setProperty(`--${varName}-rgb`, `${rgb.r} ${rgb.g} ${rgb.b}`);
                }
            };
            
            // Apply colors as CSS variables
            setColorVar("primary", colors.primary, "#6495FF");
            setColorVar("primary-dark", colors.primaryDark, "#4A6FA5");
            setColorVar("text-white", colors.textWhite, "#FFFFFF");
            setColorVar("text-accent", colors.textAccent, "#A0B5FF");
            setColorVar("text-secondary", colors.textSecondary, "#8B9DC3");
            setColorVar("border", colors.border, "#FFFFFF");
            setColorVar("header-border", colors.headerBorder, "#6495FF");
            setColorVar("player-row", colors.playerRow, "#FFFFFF");
            setColorVar("player-count-bg", colors.playerCountBg, "#6495FF");
            setColorVar("player-count-border", colors.playerCountBorder, "#6495FF");
            setColorVar("hover-bg", colors.hoverBg, "#6495FF");
            setColorVar("hover-bg-dark", colors.hoverBgDark, "#5078C8");
            setColorVar("logo-glow", colors.logoGlow, "#6495FF");
            
            // Handle background and shadow colors (they include opacity in the value)
            root.style.setProperty("--background", colors.background || "rgba(18, 18, 35, 0.95)");
            root.style.setProperty("--background-dark", colors.backgroundDark || "rgba(12, 12, 25, 0.98)");
            root.style.setProperty("--card-bg", colors.cardBg || "rgba(25, 25, 45, 0.6)");
            root.style.setProperty("--shadow-color", colors.shadowColor || "rgba(0, 0, 0, 0.3)");
            root.style.setProperty("--shadow-strong", colors.shadowStrong || "rgba(0, 0, 0, 0.5)");
            
            // Set opacity values
            root.style.setProperty("--border-opacity", colors.borderOpacity ?? 0.08);
            root.style.setProperty("--header-border-opacity", colors.headerBorderOpacity ?? 0.5);
            root.style.setProperty("--player-row-light-opacity", colors.playerRowLightOpacity ?? 0.04);
            root.style.setProperty("--player-row-dark-opacity", colors.playerRowDarkOpacity ?? 0.06);
            root.style.setProperty("--player-count-bg-opacity", colors.playerCountBgOpacity ?? 0.2);
            root.style.setProperty("--player-count-border-opacity", colors.playerCountBorderOpacity ?? 0.4);
            root.style.setProperty("--hover-bg-opacity", colors.hoverBgOpacity ?? 0.2);
            root.style.setProperty("--hover-bg-dark-opacity", colors.hoverBgDarkOpacity ?? 0.2);
            root.style.setProperty("--logo-glow-opacity", colors.logoGlowOpacity ?? 0.4);
            root.style.setProperty("--logo-glow-size", colors.logoGlowSize || "25px");
        }
    }

    if (data.action === "hudConfig" && data.hud) {
        const root = document.documentElement;
        hudEnabled = !!data.hud.enabled;

        if (data.hud.backgroundColor) {
            root.style.setProperty("--hud-bg", data.hud.backgroundColor);
        }
        if (data.hud.borderColor) {
            root.style.setProperty("--hud-border", data.hud.borderColor);
        }
        if (data.hud.textColor) {
            root.style.setProperty("--hud-text", data.hud.textColor);
        }

        hudEl.style.display = hudEnabled ? "flex" : "none";
    }

    if (data.action === "hudToggle") {
        hudEnabled = !!data.enabled;
        hudEl.style.display = hudEnabled ? "flex" : "none";
    }

    if (data.action === "hudUpdate") {
        if (data.playerId !== undefined && hudIdEl) {
            hudIdEl.textContent = `ID: ${data.playerId}`;
        }
        if (data.playerName && hudNameEl) {
            hudNameEl.textContent = data.playerName;
        }
        if (data.playerCount !== undefined && data.maxPlayers !== undefined && hudPlayersEl) {
            hudPlayersEl.textContent = `Players: ${data.playerCount} / ${data.maxPlayers}`;
        }

        if (hudEnabled) {
            hudEl.style.display = "flex";
        }
    }

    if (data.action === "update") {
        console.log("[Scoreboard] NUI received update message", data);
        if (!Array.isArray(data.players)) {
            console.error("[Scoreboard] NUI: Players data is not an array", data.players);
            return;
        }

        allPlayers = data.players;
        console.log("[Scoreboard] NUI: Player count:", allPlayers.length);
        currentPage = 1; // Reset to first page
        
        // Store current player ID if provided
        if (data.currentPlayerId !== undefined) {
            currentPlayerId = data.currentPlayerId;
        }
        
        renderPlayerPage();

        // Update player count dynamically with configured max players
        const playerCount = document.getElementById("playercount");
        playerCount.textContent = `${allPlayers.length} / ${maxPlayers}`;
    }
});
