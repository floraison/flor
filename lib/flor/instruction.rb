
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


class Flor::Instruction
#static char exe_val(fdja_value *node, fdja_value *exe)
#{
#  fdja_value *atts = attributes(node, exe);
#
#  fdja_value *val = fdja_l(atts, "_0");
#  if (val == NULL) val = fdja_v("null");
#
#  fdja_pset(exe, "payload.ret", fdja_clone(val));
#
#  fdja_free(atts);
#
#  return 'v'; // over
#}

#static fdja_value *tree(fdja_value *node, fdja_value *msg)
#{
#  fdja_value *r =  NULL;
#
#  if (msg) r = fdja_l(msg, "tree");
#
#  if (r) return r;
#
#  char *nid = fdja_ls(node, "nid", NULL);
#  if (nid == NULL) return NULL;
#
#  r = flon_node_tree(nid);
#
#  free(nid);
#
#  return r;
#}

  def initialize(node, msg)

    @node = node
    @msg = msg
  end

  def attributes
  end
end

module Flor::Ins; end

