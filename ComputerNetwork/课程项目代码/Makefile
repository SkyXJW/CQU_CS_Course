CC = gcc
CFLAGS = -Wall #-Werror
SRCS = pack.c utils.c unpack.c main.c
OBJS = $(SRCS:.c=.o)

all: my_program

my_program: $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o my_program

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

run: my_program
	./my_program