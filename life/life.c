#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define DX(y,x,w) ((y)*(w)+(x))

int main(int ac, char **av)
{
    if (ac != 4)   return (1);
    int w = atoi(av[1]);
    int h = atoi(av[2]);
    int iter = atoi(av[3]);

    if (w <= 0 || h <= 0 || iter < 0)
        return(1);
    int *board = calloc(w * h, sizeof(int));
    int *next = calloc(w * h, sizeof(int));
    if (!board || !next)
        return (1);
    
    int x = 0, y = 0, pen = 0;
    char c;

    while (read(0, &c, 1) == 1)
    {
        if (c == 'w' && y > 0) y --;
        else if (c == 's' && y < h -1) y++;
        else if (c == 'a' && x > 0) x--;
        else if (c == 'd' && x < w - 1) x++; 
        else if (c == 'x') pen = !pen;
        if (pen)
            board[DX(y,x,w)] = 1;
    }


    for (int t = 0 ; t < iter ; t++)
    {
        for (int i = 0 ; i < h ; i ++)
        {
            for (int j = 0; j < w ; j ++)
            {
                int n = 0;
                for (int di = -1; di <= 1 ; di ++)
                {
                    for (int dj = -1; dj <= 1 ; dj ++)
                    {
                        int ni = di + i;
                        int nj = dj + j;
                        if ((di || dj) && ni >= 0 && ni < h && nj >= 0 && nj < w)
                            n += board[DX(ni, nj, w)];
                    }
                }
                int alive = board[DX(i, j, w)];
                next[DX(i, j, w)] = (alive && (n == 2 || n == 3)) || (!alive && n == 3); 
            }
        }
        int *tmp = next;
        next = board;
        board = tmp;
    }
    
    for (int i = 0 ; i < h ; i ++) {
        for (int j = 0; j < w ; j ++) {
            char out = board[DX(i, j, w)] ? 'O' : ' ';
            putchar(out);
	    }
        putchar(10);
    }

    free(board), free(next);
}
