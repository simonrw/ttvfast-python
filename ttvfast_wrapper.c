#include <Python.h>
#include <stdio.h>
#include "transit.h"
#include "myintegrator.h"

void TTVFast(double *params,double dt, double Time, double total,int n_plan,CalcTransit *transit,CalcRV *RV_struct, int nRV, int n_events, int input_flag);

static char module_docstring[] = "Wrapping functions code";
static char ttvfast_docstring[] = "Change a value";

static PyObject *ttvfast_ttvfast(PyObject *self, PyObject *args);

static PyMethodDef module_methods[] = {
    {"ttvfast", ttvfast_ttvfast, METH_VARARGS, ttvfast_docstring},
    {NULL, NULL, 0, NULL}
};

PyMODINIT_FUNC initttvfast(void)
{
    PyObject *m = Py_InitModule3("ttvfast", module_methods, module_docstring);
    if (m == NULL) {
        return;
    }
}

/* Takes integer and changes the value in place */
static PyObject *ttvfast_ttvfast(PyObject *self, PyObject *args) {
    PyObject *params_obj, *planet_obj, *epoch_obj, *time_obj, *rsky_obj, *vsky_obj, *out;
    double dt, Time, total;
    int n_plan, n_events, input_flag;
    int i;

    if (!PyArg_ParseTuple(args, "Odddiii", &params_obj, &dt, &Time, &total,
                &n_plan, &n_events, &input_flag)) {
        return NULL;
    }

#ifdef DEBUG
    printf("dt: %lf\n", dt);
    printf("Time: %lf\n", Time);
    printf("total: %lf\n", total);
    printf("n_plan: %d\n", n_plan);
    printf("n_events: %d\n", n_events);
    printf("input_flag: %d\n", input_flag);
#endif

    /* Get the params list */
    double *params = malloc(sizeof(double) * (2 + n_plan * 7));
    PyObject *item;
    for (i=0; i<(2 + n_plan * 7); i++) {
        item = PySequence_GetItem(params_obj, i);
        params[i] = PyFloat_AsDouble(item);
#ifdef DEBUG
        printf("Params %d: %lf\n", i, params[i]);
#endif
    }

    CalcTransit *model;
    model = (CalcTransit*)calloc(n_events, sizeof(CalcTransit));
    double DEFAULT = -2; /* value for transit information that is not determined by TTVFast*/
    for(i=0;i<n_events;i++){
        (model+i)->time = DEFAULT;
    }

#ifdef DEBUG
    printf("Transit model container created\n");
#endif
    TTVFast(params, dt, Time, total, n_plan, model, NULL, 0, n_events, input_flag);
#ifdef DEBUG
    printf("Called\n");
#endif

    planet_obj = PyList_New(n_events);
    epoch_obj = PyList_New(n_events);
    time_obj = PyList_New(n_events);
    rsky_obj = PyList_New(n_events);
    vsky_obj = PyList_New(n_events);

#ifdef DEBUG
    printf("Creating output lists\n");
#endif
    for (i=0; i<n_events; i++) {
        item = PyInt_FromLong((model+i)->planet);
        PyList_SetItem(planet_obj, i, item);

        item = PyInt_FromLong((model+i)->epoch);
        PyList_SetItem(epoch_obj, i, item);

        item = PyFloat_FromDouble((model+i)->time);
        PyList_SetItem(time_obj, i, item);

        item = PyFloat_FromDouble((model+i)->rsky);
        PyList_SetItem(rsky_obj, i, item);

        item = PyFloat_FromDouble((model+i)->vsky);
        PyList_SetItem(vsky_obj, i, item);
    }

    free(model);
    free(params);

    out = PyTuple_New(5);
    PyTuple_SetItem(out, 0, planet_obj);
    PyTuple_SetItem(out, 1, epoch_obj);
    PyTuple_SetItem(out, 2, time_obj);
    PyTuple_SetItem(out, 3, rsky_obj);
    PyTuple_SetItem(out, 4, vsky_obj);

    return out;
}
