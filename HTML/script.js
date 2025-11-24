window.addEventListener("message", function(event) {
    if (event.data.action === "toggle") {
        document.getElementById("scoreboard").style.display =
            event.data.show ? "block" : "none";
    }

    if (event.data.action === "update") {
        const list = document.getElementById("playerlist");
        list.innerHTML = "";

        event.data.players.forEach(player => {
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
