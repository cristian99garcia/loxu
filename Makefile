VALAC = valac
VALAPKG = --pkg gtk+-3.0 \
          --pkg gdk-3.0 \
          --pkg gee-0.8 \
          --pkg gdk-pixbuf-2.0

SRC = src/loxu.vala \
      src/window.vala \
      src/entry.vala \
      src/headerbar.vala \
      src/notebook.vala \
      src/view.vala \
      src/utils.vala

BIN = loxu

all:
	$(VALAC) $(VALAPKG) $(SRC) -o $(BIN)

clean:
	rm -f $(BIN)

