let currentPage = 1;
let allPlayers = [];
let maxPlayers = 32;
let currentPlayerId = null;
let highlightEnabled = true;
let highlightColor = "#6495FF";
let logoEnabled = true;
let colors = {};
const playersPerPage = 12;

function renderPlayerPage() {
    const list = document.getElementById("playerlist");
    list.innerHTML = "";

    const startIdx = (currentPage - 1) * playersPerPage;
    const endIdx = startIdx + playersPerPage;
    const pagePlayers = allPlayers.slice(startIdx, endIdx);

    pagePlayers.forEach(player => {
        const row = document.createElement("tr");
        
        // Apply highlight to current player if enabled
        if (highlightEnabled && player.id === currentPlayerId) {
            row.classList.add("current-player");
            row.style.setProperty("--highlight-color", highlightColor);
        }
        
        row.innerHTML = `
            <td>${player.id}</td>
            <td>${player.name}</td>
        `;
        list.appendChild(row);
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
        }
        
        // Store and apply colors from config
        if (data.colors && Object.keys(data.colors).length > 0) {
            colors = data.colors;
            
            // Apply colors as CSS variables
            root.style.setProperty("--primary", colors.primary || "#6495FF");
            root.style.setProperty("--primary-dark", colors.primaryDark || "#4A6FA5");
            root.style.setProperty("--text-white", colors.textWhite || "#FFFFFF");
            root.style.setProperty("--text-accent", colors.textAccent || "#A0B5FF");
            root.style.setProperty("--background", `rgba(20, 20, 40, ${colors.background ? colors.background.replace(/[^\d.]/g, '') : 0.92})`);
            root.style.setProperty("--background-dark", `rgba(10, 10, 25, ${colors.backgroundDark ? colors.backgroundDark.replace(/[^\d.]/g, '') : 0.95})`);
            root.style.setProperty("--border", colors.border || "#FFFFFF");
            root.style.setProperty("--border-opacity", colors.borderOpacity || 0.1);
            root.style.setProperty("--header-border", colors.headerBorder || "#6495FF");
            root.style.setProperty("--header-border-opacity", colors.headerBorderOpacity || 0.4);
            root.style.setProperty("--player-row", colors.playerRow || "#FFFFFF");
            root.style.setProperty("--player-row-light-opacity", colors.playerRowLightOpacity || 0.03);
            root.style.setProperty("--player-row-dark-opacity", colors.playerRowDarkOpacity || 0.05);
            root.style.setProperty("--player-count-bg", colors.playerCountBg || "#6495FF");
            root.style.setProperty("--player-count-bg-opacity", colors.playerCountBgOpacity || 0.15);
            root.style.setProperty("--player-count-border", colors.playerCountBorder || "#6495FF");
            root.style.setProperty("--player-count-border-opacity", colors.playerCountBorderOpacity || 0.3);
            root.style.setProperty("--hover-bg", colors.hoverBg || "#6495FF");
            root.style.setProperty("--hover-bg-opacity", colors.hoverBgOpacity || 0.15);
            root.style.setProperty("--hover-bg-dark", colors.hoverBgDark || "#5078C8");
            root.style.setProperty("--hover-bg-dark-opacity", colors.hoverBgDarkOpacity || 0.15);
            root.style.setProperty("--logo-glow", colors.logoGlow || "#6495FF");
            root.style.setProperty("--logo-glow-opacity", colors.logoGlowOpacity || 0.3);
            root.style.setProperty("--logo-glow-size", colors.logoGlowSize || "20px");
        }
    }

    if (data.action === "update") {
        if (!Array.isArray(data.players)) return;

        allPlayers = data.players;
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
