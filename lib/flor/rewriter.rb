#--
# Copyright (c) 2015-2016, John Mettraux, jmettraux+flon@gmail.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Made in Japan.
#++


class Flor::Rewriter < Flor::TransientExecutor

#def rewrite_parens(node, message, tree)
#
#  return tree unless tree[1].values.find { |c| is_tree?(c) }
#
#  ln = tree[2]
#  catts = {}
#  core = [ tree[0], catts, ln, tree[3] ]
#  schildren = []
#
#  j = 0
#  tree[1].each do |k, v|
#    if is_tree?(v)
#      schildren << [ 'set', { '_0' => "w._#{j}" }, ln, [ v ] ]
#      catts[k] = "$(w._#{j})"
#      j = j + 1
#    else
#      catts[k] = v
#    end
#  end
#
#  schildren << core
#
#  [ 'sequence', {}, ln, schildren, *tree[4] ]
#end
  TREE =
    Flor::Radial.parse(%{
      sequence

        define rewrite_parens tree
          # return unless there is a tree among the attributes
          1

        rewrite_parens t
    }, __FILE__)

  def self.rewrite(tree)

#    r = self.new({}).launch(TREE, vars: { 't' => tree })
#pp r unless r['point'] == 'failed'

    tree
  end

  protected

  def rewrite(tree)

    tree
  end
end

