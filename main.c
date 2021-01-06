#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

typedef struct SInput {
    int w, h;
    float* M;
    float weight;

    int steps;
    float* step_cols;
} Input;

void loadTab(const char* filename, Input* data)
{
    FILE *input;
    input = fopen(filename, "r");

    if(input == NULL)
    {
        printf("Error opening file!\n");
        exit(1);
    }

    fscanf(input, "%d %d %f", &data->w, &data->h, &data->weight);

    data->M = malloc(data->w * data->h * sizeof(float));

    for (int i = 0; i < data->h; ++i)
    {
        for (int j = 0; j < data->w; ++j)
        {
            fscanf(input, "%f", &(data->M)[j * data->h + i]);
        }
    }

    fscanf(input, "%d", &data->steps);

    data->step_cols = malloc(data->steps * data->h * sizeof(float));

    for (int n = 0; n < data->steps; ++n)
    {
        for (int i = 0; i < data->h; ++i)
        {
            fscanf(input, "%f", &(data->step_cols)[n * data->h + i]);
        }
    }

    fclose(input);
}

void printTab(Input* data)
{
    for (int i = 0; i < data->h; ++i)
    {
        for (int j = 0; j < data->w; ++j)
        {
            printf("%.2f ", (data->M)[j * data->h + i]);
        }

        printf("\n");
    }
}

extern void start(int w, int h, float *M, float weight);
extern void step(float T[]);

int main(int argc, char** argv)
{
    if (argc == 2)
    {
        Input data;
        loadTab(argv[1], &data);

        start(data.w, data.h, data.M, data.weight);

        printf("Loaded matrix:\n");
        printTab(&data);
        for (int i = 0; i < data.steps; ++i)
        {
            printf("----------------------------------\n");
            printf("Step %d:\n", i + 1);
            step(&data.step_cols[i * data.h]);
            printTab(&data);
            usleep(200000);
        }
    }
    else
    {
        printf("Usage: ./flow <file_path>\n");
        printf("Example: ./flow tests/small.txt\n\n");
    }

    return 0;
}
