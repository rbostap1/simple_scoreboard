window.addEventListener("message", function (event) {
    const data = event.data;

    if (data.action === "toggle") {
        const sb = document.getElementById("scoreboard");
        if (data.show) {
            sb.style.display = "block";
            // Trigger animation after display is set
            setTimeout(() => sb.classList.add("show"), 10);
        } else {
            sb.classList.remove("show");
            // Hide after animation completes
            setTimeout(() => sb.style.display = "none", 300);
        }
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
        const list = document.getElementById("playerlist");
        const playerCount = document.getElementById("player-count");
        
        list.innerHTML = "";

        if (!Array.isArray(data.players)) return;

        // Update player count
        const count = data.players.length;
        playerCount.textContent = `${count} Player${count !== 1 ? 's' : ''} Online`;

        data.players.forEach((player, index) => {
            const row = document.createElement("tr");
            row.style.animationDelay = `${index * 0.03}s`;

            row.innerHTML = `
                <td>${player.id}</td>
                <td>${player.name}</td>
            `;

            list.appendChild(row);
        });
    }
});
