"""
cLitter = (TOTLITC + CWDC)/1000.0
"""
from __future__ import absolute_import, division, print_function, unicode_literals

import cmor
from e3sm_to_cmip.lib import handle_variables

# list of raw variable names needed
RAW_VARIABLES = [str('TOTLITC'), str('CWDC')]
VAR_NAME = str('cLitter')
VAR_UNITS = str('kg m-2')
TABLE = str('CMIP6_Lmon.json')

def write_data(varid, data, timeval, timebnds, index, **kwargs):
    """
    cLitter = (TOTLITC + CWDC)/1000.0
    """
    outdata = (data['TOTLITC'][index, :] + data['CWDC'][index, :])/1000.0
    if kwargs.get('simple'):
        return outdata
    cmor.write(
        varid,
        outdata,
        time_vals=timeval,
        time_bnds=timebnds)
    return outdata
# ------------------------------------------------------------------


def handle(infiles, tables, user_input_path, **kwargs):

    return handle_variables(
        metadata_path=user_input_path,
        tables=tables,
        table=kwargs.get('table', TABLE),
        infiles=infiles,
        raw_variables=RAW_VARIABLES,
        write_data=write_data,
        outvar_name=VAR_NAME,
        outvar_units=VAR_UNITS,
        serial=kwargs.get('serial'),
        logdir=kwargs.get('logdir'),
        simple=kwargs.get('simple'),
        outpath=kwargs.get('outpath'))
# ------------------------------------------------------------------
