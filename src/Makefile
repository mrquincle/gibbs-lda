CC=		g++

OBJS=		strtokenizer.o dataset.o utils.o model.o
MAIN=		lda
 
all:	$(OBJS) $(MAIN).cpp
	$(CC) -o $(MAIN) $(MAIN).cpp $(OBJS)
	strip $(MAIN)

strtokenizer.o:	strtokenizer.h strtokenizer.cpp
	$(CC) -c -o strtokenizer.o strtokenizer.cpp

dataset.o:	dataset.h dataset.cpp
	$(CC) -c -o dataset.o dataset.cpp

utils.o:	utils.h utils.cpp
	$(CC) -c -o utils.o utils.cpp

model.o:	model.h model.cpp
	$(CC) -c -o model.o model.cpp

test:
	

clean:
	rm $(OBJS) 
	rm $(MAIN)

