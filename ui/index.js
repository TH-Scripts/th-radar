function openMenu() {
  $(".container").fadeIn().draggable();
}

function closeMenu() {
  $(".container").hide();
}

window.addEventListener("message", function (event) {
  const item = event.data;
  const speedElement = $(".speed");
  const plateElement = $(".plate");

  if (item.display) {
    openMenu();
  } else if (!item.display) {
    closeMenu();
  }

  if (speedElement.length > 0) {
    const paddedSpeed = ("000" + item.speed).slice(-3);

    if (item.frozen) {
      speedElement.html(`<span class="frozen-speed">${paddedSpeed}</span>`);
    } else {
      speedElement.html(paddedSpeed);
    }
  }

  if (plateElement.length > 0) {
    plateElement.html(item.plate);
  }
});

$(document).on("keyup", function (data) {
  if (data.which == 27) {
    $.post("https://th-radar/key", JSON.stringify({}));
  }
});
