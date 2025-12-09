let currentPage = 1;
let allPlayers = [];
const playersPerPage = 12;

function renderPlayerPage() {
    const list = document.getElementById("playerlist");
    list.innerHTML = "";

    const startIdx = (currentPage - 1) * playersPerPage;
    const endIdx = startIdx + playersPerPage;
    const pagePlayers = allPlayers.slice(startIdx, endIdx);

    pagePlayers.forEach(player => {
        const row = document.createElement("tr");
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

        if (data.serverName) {
            nameEl.textContent = data.serverName;
        }

        if (data.logo && data.logo !== "") {
            logoEl.src = data.logo;
            logoEl.style.display = "block";
        } else {
            logoEl.style.display = "none";
        }
    }

    if (data.action === "update") {
        if (!Array.isArray(data.players)) return;

        allPlayers = data.players;
        currentPage = 1; // Reset to first page
        renderPlayerPage();

        // Update player count (show current/32 format)
        const playerCount = document.getElementById("playercount");
        playerCount.textContent = `${allPlayers.length} / 32`;
    }
});
