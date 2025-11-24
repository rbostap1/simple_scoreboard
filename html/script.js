window.addEventListener("message", function(event) {
    const data = event.data;

    if (data.action === "toggle") {
        document.getElementById("scoreboard").style.display =
            data.show ? "block" : "none";
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
        list.innerHTML = "";

        data.players.forEach(player => {
            const row = document.createElement("tr");

            row.innerHTML = `
                <td>${player.id}</td>
                <td>${player.name}</td>
                <td>${player.ping}</td>
            `;

            list.appendChild(row);
        });
    }
});
