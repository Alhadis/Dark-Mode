CMD     = dark-mode
BIN_DIR = /usr/local/bin
MAN_DIR = /usr/local/share/man/man1
BIN_OBJ = $(BIN_DIR)/$(CMD)
MAN_OBJ = $(MAN_DIR)/$(CMD).1

all: install


# Create missing directories as needed
$(BIN_DIR) $(MAN_DIR):
	mkdir -p "$(@D)"


# Install executable and manual page
install: $(BIN_OBJ) $(MAN_OBJ)

$(BIN_OBJ): $(BIN_DIR) dark-mode
	install -C dark-mode $@

$(MAN_OBJ): $(MAN_DIR) dark-mode.1
	cp -f dark-mode.1 $@


# Install program and manual page as symbolic links
link: $(BIN_DIR) $(MAN_DIR)
	ln -sf "$(PWD)/dark-mode"   $(BIN_OBJ)
	ln -sf "$(PWD)/dark-mode.1" $(MAN_OBJ)


# Remove an earlier installation
uninstall:
	rm -f $(BIN_DIR)/dark-mode
	rm -f $(MAN_DIR)/dark-mode.1

.PHONY: uninstall
