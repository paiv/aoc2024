from xml.dom.minidom import getDOMImplementation


class SvgNode:

    def __init__(self, /, el, doc):
        self.doc = doc
        self.el = el

    def __getitem__(self, key):
        return self.el.getAttribute(key)

    def __setitem__(self, key, value):
        if value is not None:
            value = str(value)
        self.el.setAttribute(key, value)

    def __str__(self):
        return str(self.el.toprettyxml())

    def prettyprint(self, file):
        self.el.writexml(file, addindent='\t', newl='\n')

    @property
    def text(self):
        return ''.join(c.data for c in self.el.childNodes)

    @text.setter
    def text(self, value):
        while (c := self.el.lastChild):
            self.el.removeChild(c)
        el = self.doc.createTextNode(value)
        self.el.appendChild(el)

    def add_element(self, tag):
        el = self.doc.createElement(tag)
        self.el.appendChild(el)
        return SvgNode(el=el, doc=self.doc)

    def add_rect(self, x, y, w, h, /, fill=None):
        el = self.add_element('rect')
        el['x'] = x
        el['y'] = y
        el['width'] = w
        el['height'] = h
        if fill is not None:
            el['fill'] = fill
        return el

    def add_circle(self, cx, cy, r, /, fill=None):
        el = self.add_element('circle')
        el['cx'] = cx
        el['cy'] = cy
        el['r'] = r
        if fill is not None:
            el['fill'] = fill
        return el

    def add_path(self, points, /, fill=None, stroke=None):
        el = self.add_element('path')
        el['d'] = self._make_path(points)
        if fill is not None:
            el['fill'] = fill
        if stroke is not None:
            el['stroke'] = stroke
        return el

    def add_style(self, text):
        el = self.add_element('style')
        el.text = text
        return el

    def add_text(self, x, y, text, /, fill=None, stroke=None):
        el = self.add_element('text')
        el['x'] = x
        el['y'] = y
        if fill is not None:
            el['fill'] = fill
        if stroke is not None:
            el['stroke'] = stroke
        el.text = text
        return el

    def _make_path(self, points):
        px,py = points[0]
        so = f'M {x},{y}'
        if len(points) <= 1:
            return so
        x,y = points[1]
        dx,dy = x-px, y-py
        px,py = x, y
        so += f' l {dx},{dy}'
        if len(points) <= 2:
            return so
        for x,y in points[2:]:
            dx,dy = x-px, y-py
            px,py = x, y
            so += f' {dx},{dy}'
        return so

    @property
    def width(self):
        return self['width']

    @width.setter
    def width(self, value):
        self['width'] = value

    @property
    def height(self):
        return self['height']

    @height.setter
    def height(self, value):
        self['height'] = value


class Svg (SvgNode):
    _impl = getDOMImplementation()

    def __init__(self):
        dt = self._impl.createDocumentType('svg', '-//W3C//DTD SVG 1.1//EN',
            'http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd')
        self.doc = self._impl.createDocument('http://www.w3.org/2000/svg', 'svg', dt)
        self.root = self.doc.documentElement
        super().__init__(el=self.root, doc=self.doc)
        self['version'] = '1.1'
        self['xmlns'] = self.root.namespaceURI
        self.viewbox = (0, 0, 0, 0)

    def prettyprint(self, file):
        self.doc.writexml(file, addindent='\t', newl='\n', encoding='utf-8')

    @property
    def viewbox(self):
        s = self['viewBox']
        if s:
            x,y,w,h = s.split()
        return (x,y,w,h)

    @viewbox.setter
    def viewbox(self, value):
        if isinstance(value, (list, tuple)):
            x,y,w,h = value
            value = f'{x} {y} {w} {h}'
        self['viewBox'] = value

