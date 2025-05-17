from pyotherside_utils import *
import cattrs

class CattrsConfigBase(JSONConfigBase):
    _extension = 'json'
    _model: Any = Any
    "The model to use when structuring data. See https://catt.rs/en/v22.1.0/structuring.html"
    _unstructure_as: Any = None
    "Same as the argument in cattrs.unstructure."

    def _load(self, data):
        @exception_safe({cattrs.ClassValidationError: ExceptionHandlingInfo(*self.get_error('Cattrs'), return_on_exc=(False, None))})
        def wrapper():
            state, decoded = super()._load(data)
            if not state:
                return False, None
            return True, cattrs.structure(decoded, self._model)
        return wrapper()

    def _dump(self, data):
        return super()._dump(cattrs.unstructure(data, self._unstructure_as))