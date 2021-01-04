#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>


float* M_;
float* M_temp_;
int w_, h_;
float weight_;

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

void start(int w, int h, float *M, float weight)
{
    w_ = w;
    h_ = h;
    M_ = M;
    weight_ = weight;

    M_temp_ = malloc(w * h * sizeof(float));
}

void applyCol(float T[], int row)
{
    int ptr = row * h_;
    float val = M_[ptr];
    float diff = T[0] + T[1] + M_[ptr + 1] - 3 * val;
    M_temp_[ptr] = val + diff * weight_;

    int i = 1;
    for (; i < h_ - 1; ++i)
    {
        ++ptr;
        val = M_[ptr];
        diff = T[i - 1] + T[i] + T[i + 1] + M_[ptr + 1] + M_[ptr - 1] - 5 * val;
        M_temp_[ptr] = val + diff * weight_;
    }
    ++ptr;

    val = M_[ptr];
    diff = T[i - 1] + T[i] + M_[ptr - 1] - 3 * val;
    M_temp_[ptr] = val + diff * weight_;

}

void run(float T[])
{
    applyCol(T, 0);

    for (int j = 0; j < w_ - 1; ++j)
    {
        applyCol(&M_[j * h_], j + 1);
    }

    for (int i = 0; i < w_ * h_; ++i)
    {
        M_[i] = M_temp_[i];
    }
}

int main(int argc, char** argv)
{
    if (argc == 2)
    {
        Input data;
        loadTab(argv[1], &data);
        start(data.w, data.h, data.M, data.weight);
        for (int i = 0; i < data.steps; ++i)
        {
            printf("---------------\n");
            printTab(&data);
            run(&data.step_cols[i * data.h]);
            usleep(200000);
        }
    }
    else
    {
        printf("Usage: ./game <file_path>\n");
        printf("Example: ./game tests/glider.txt\n\n");
    }

    return 0;
}
