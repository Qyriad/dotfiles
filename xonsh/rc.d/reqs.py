try:
    import requests

    #
    # You want to see cursed? I'll give you cursed~
    #
    def response_repr(self):
        s = [f"<Response [{self.status_code}]>"]
        try:
            if json_data := self.json():
                s.append(str(json_data))
            elif self.content:
                s.append(self.content.decode(errors="backslashreplace"))

            return "\n".join(s)
        except requests.exceptions.JSONDecodeError:
            return self._original_repr()

    requests.Response._original_repr = requests.Response.__repr__
    requests.Response.__repr__ = response_repr
except ImportError:
    pass
