#include <Python.h>
#ifdef DEBUG
#include <stdio.h>
#endif
#include "transit.h"
#include "myintegrator.h"
#include "ttv_errors.h"

#if PY_MAJOR_VERSION >= 3
#define PyInteger_FromLong PyLong_FromLong
#else
#define PyInteger_FromLong PyInt_FromLong
#endif

#define STR(x) #x
#define PRINT_REFCNT(x) (printf("Refcount for %s: %u\n", #x, Py_REFCNT(x)))

status_t TTVFast_main(double *params,double dt, double Time, double total,int n_plan,CalcTransit *transit,CalcRV *RV_struct, int nRV, int n_events, int input_flag);

static PyObject *_ttvfast__ttvfast(PyObject *self, PyObject *args);

static char module_docstring[] = "";
static char _ttvfast_docstring[] = "";

struct module_state {
    PyObject *error;
};

#if PY_MAJOR_VERSION >= 3
#define GETSTATE(m) ((struct module_state*)PyModule_GetState(m))
#else
#define GETSTATE(m) (&_state)
static struct module_state _state;
#endif

static PyMethodDef _ttvfast_methods[] = {
    {"_ttvfast", (PyCFunction)_ttvfast__ttvfast, METH_VARARGS, _ttvfast_docstring},
    {NULL, NULL}
};

#if PY_MAJOR_VERSION >= 3

static int _ttvfast_traverse(PyObject *m, visitproc visit, void *arg) {
    Py_VISIT(GETSTATE(m)->error);
    return 0;
}

static int _ttvfast_clear(PyObject *m) {
    Py_CLEAR(GETSTATE(m)->error);
    return 0;
}


static struct PyModuleDef moduledef = {
        PyModuleDef_HEAD_INIT,
        "_ttvfast",
        module_docstring,
        sizeof(struct module_state),
        _ttvfast_methods,
        NULL,
        _ttvfast_traverse,
        _ttvfast_clear,
        NULL
};

#define INITERROR return NULL

PyObject *
PyInit__ttvfast(void)

#else
#define INITERROR return

void
init_ttvfast(void)
#endif
{
#if PY_MAJOR_VERSION >= 3
    PyObject *module = PyModule_Create(&moduledef);
#else
    PyObject *module = Py_InitModule3("_ttvfast", _ttvfast_methods, module_docstring);
#endif

    if (module == NULL)
        INITERROR;
    struct module_state *st = GETSTATE(module);

    st->error = PyErr_NewException("_ttvfast.Error", NULL, NULL);
    if (st->error == NULL) {
        Py_DECREF(module);
        INITERROR;
    }

#if PY_MAJOR_VERSION >= 3
    return module;
#endif
}

/* Takes integer and changes the value in place */
static PyObject *_ttvfast__ttvfast(PyObject *self, PyObject *args) {
    PyObject *params_obj, *planet_obj, *epoch_obj, *time_obj, *rsky_obj, *vsky_obj, *rv_times_obj, *rv_out_obj, *item;
    double dt, Time, total;
    int n_plan, n_events, input_flag, len_rv;
    int i;
    status_t status = STATUS_OK;

    n_events = 5000;

    if (!PyArg_ParseTuple(args, "Odddiii|O", &params_obj, &dt, &Time, &total,
                &n_plan, &input_flag, &len_rv, &rv_times_obj)) {
        return NULL;
    }

#ifdef DEBUG
    printf("dt: %lf\n", dt);
    printf("Time: %lf\n", Time);
    printf("total: %lf\n", total);
    printf("n_plan: %d\n", n_plan);
    printf("input_flag: %d\n", input_flag);
    printf("len_rv: %d\n", len_rv);
#endif


    /* Get the params list */
    double *params = malloc(sizeof(double) * (2 + n_plan * 7));
    for (i=0; i<(2 + n_plan * 7); i++) {
        item = PyList_GetItem(params_obj, i);
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

    CalcRV *RV_model;
    if (len_rv) {
        RV_model = (CalcRV*)calloc(len_rv, sizeof(CalcRV));
        for (int i=0; i<len_rv; i++) {
            item = PyList_GetItem(rv_times_obj, i);
            (RV_model+i)->time = PyFloat_AsDouble(item);
        }
    } else {
        RV_model = NULL;
    }

#ifdef DEBUG
    printf("Transit model container created\n");
#endif
    status = TTVFast_main(params, dt, Time, total, n_plan, model, RV_model, len_rv, n_events, input_flag);
#ifdef DEBUG
    printf("Called\n");
#endif

    /* Check the error status value */
    if (status != STATUS_OK) {
        switch (status) {
            case STATUS_OK:
                break;
            case STATUS_ARGUMENT_ERROR:
                PyErr_Format(PyExc_ValueError, "Input flag must be 0, 1, or 2.");
                break;
            case STATUS_MEMORY_ERROR:
                PyErr_Format(PyExc_MemoryError, "Not enough memory allocated for Transit structure: "
                        "more events triggering as transits than expected. "
                        "Possibily indicative of larger problem.");
                break;
            case STATUS_HYPERBOLIC_ORBIT:
                PyErr_Format(PyExc_ValueError, "Hyperbolic orbit.");
                break;
            case STATUS_TOO_MANY_PLANETS:
                PyErr_Format(PyExc_ValueError, "Too many planets.");
                break;
            case STATUS_NON_CONVERGING:
                PyErr_Format(PyExc_ValueError, "Kepler step not converging in MAX_ITER. "
                        "Likely need a smaller dt.");
                break;
            default:
                PyErr_Format(PyExc_ValueError, "Unknown exit status from TTVFast: %d.",
                        (int)status);
                break;
        }
    }

    planet_obj = PyList_New(n_events);
    epoch_obj = PyList_New(n_events);
    time_obj = PyList_New(n_events);
    rsky_obj = PyList_New(n_events);
    vsky_obj = PyList_New(n_events);
    rv_out_obj = PyList_New(len_rv);

#ifdef DEBUG
    printf("Creating output lists\n");
#endif
    for (i=0; i<n_events; i++) {
        item = PyInteger_FromLong((model+i)->planet);
        PyList_SetItem(planet_obj, i, item);

        item = PyInteger_FromLong((model+i)->epoch);
        PyList_SetItem(epoch_obj, i, item);

        item = PyFloat_FromDouble((model+i)->time);
        PyList_SetItem(time_obj, i, item);

        item = PyFloat_FromDouble((model+i)->rsky);
        PyList_SetItem(rsky_obj, i, item);

        item = PyFloat_FromDouble((model+i)->vsky);
        PyList_SetItem(vsky_obj, i, item);
    }

    for (int i=0; i<len_rv; i++) {
        item = PyFloat_FromDouble((RV_model+i)->RV);
        PyList_SetItem(rv_out_obj, i, item);
    }

    free(model);
    free(params);
    free(RV_model);

    PyObject *positions_out = Py_BuildValue("OOOOO", planet_obj, epoch_obj, time_obj, rsky_obj, vsky_obj);

    Py_XDECREF(planet_obj);
    Py_XDECREF(epoch_obj);
    Py_XDECREF(time_obj);
    Py_XDECREF(rsky_obj);
    Py_XDECREF(vsky_obj);

    PyObject *retval;
    if (len_rv) {
        retval = Py_BuildValue("OO", positions_out, rv_out_obj);
        Py_XDECREF(rv_out_obj);
    } else {
        Py_INCREF(Py_None);
        retval = Py_BuildValue("OO", positions_out, Py_None);
    }
    Py_XDECREF(positions_out);
    return retval;
}
