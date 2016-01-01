
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

module Flor

  def self.lookup_instruction(s, mode)

    # TODO rewrite me with detection of actual implemented instructions

    return s if %w[
      > call elif elsif else if set sub task trace unless ].include?(s)

    nil
  end

  def self.is_callable?(s)

    # TODO

    false
  end

  def self.is_val?(t)

    # TODO

    false
  end

#static int rewrite_as_call_invoke_or_val(
#  fdja_value *node, fdja_value *msg, fdja_value *tree)
#{
#  int r = 0; // "not rewritten" for now
#
#  fdja_value *vname = fdja_l(tree, "0");
#  char *name = NULL;
#
#  if ( ! fdja_is_stringy(vname)) goto _over;
#
#  name = fdja_to_string(vname);
#
#  if (lookup_instruction('e', name)) goto _over;
#
#  r = 1; // "rewritten" for now
#
#  fdja_value *v = lookup_var(node, 'l', name); // 'l' for "local"
#
#  if (is_callable(v))
#  {
#    //fdja_psetv(node, "inst", "call");
#    fdja_replace(fdja_l(tree, "0"), fdja_s("call"));
#    unshift_attribute(name, tree);
#  }
#  else if (fdja_lz(tree, "1") == 0 && fdja_lz(tree, "3") == 0)
#  {
#    fdja_replace(fdja_l(tree, "0"), fdja_s("val"));
#    unshift_attribute(name, tree);
#  }
#  else
#  {
#    r = 0;
#  }
  def self.rewrite_as_call_invoke_or_val(t)

    name = t[0]

    return nil unless name.is_a?(String)
    return nil if lookup_instruction(name, 'e')

    v = name # TODO rep me with lookup_var(node, 'l', name) # 'l' for "local"

    if is_callable?(v)
      return [ 'call', *tree[1..-1] ]
    end
    if is_val?(t)
      return nil # TODO
    end

    nil
  end

#static int rewrite_infix(
#  const char *op, fdja_value *node, fdja_value *msg, fdja_value *tree)
#{
#  //if (fdja_strcmp(fdja_value_at(tree, 0), op) == 0) return 0;
#
#  fdja_value *atts = fdja_value_at(tree, 1);
#  fdja_value *line = fdja_value_at(tree, 2);
#
#  int seen = 0;
#  for (fdja_value *a = atts->child; a; a = a->sibling)
#  {
#    if (is_op(a, op)) { seen = 1; break; }
#  }
#  if ( ! seen) return 0;
#
#  fdja_value *t = fdja_array_malloc();
#  fdja_push(t, fdja_s(op));
#  /*fdja_value *natts = */fdja_push(t, fdja_object_malloc());
#  fdja_push(t, fdja_clone(line));
#  fdja_value *nchildren = fdja_push(t, fdja_array_malloc());
#
#  flu_list *l = flu_list_malloc();
#  flu_list_add(l, fdja_value_at(tree, 0));
#
#  fdja_value *a = atts->child;
#  for (; ; a = a->sibling)
#  {
#    if (l == NULL) l = flu_list_malloc();
#
#    if (a && ! is_op(a, op)) { flu_list_add(l, a); continue; }
#
#    fdja_push(nchildren, l_to_tree(l, line, node, msg));
#
#    flu_list_free(l); l = NULL;
#
#    if (a == NULL) break;
#  }
#
#  fdja_replace(tree, t);
#
#  return 1;
#}
  def self.rewrite_infix(op, t)

    nil
  end

#static int rewrite_prefix(
#  const char *op, fdja_value *node, fdja_value *msg, fdja_value *tree)
#{
#  if (fdja_strcmp(fdja_value_at(tree, 0), op) != 0) return 0;
#
#  fdja_value *children = fdja_value_at(tree, 3);
#  if (children->child != NULL) return 0;
#
#  fdja_value *atts = fdja_value_at(tree, 1);
#  fdja_value *line = fdja_value_at(tree, 2);
#
#  fdja_value *t = fdja_array_malloc();
#  fdja_push(t, fdja_s(op));
#  fdja_push(t, fdja_object_malloc());
#  fdja_push(t, fdja_clone(line));
#  fdja_value *nchildren = fdja_push(t, fdja_array_malloc());
#
#  for (fdja_value *a = atts->child; a; a = a->sibling)
#  {
#    flu_list *l = flu_list_malloc(); flu_list_add(l, a);
#    fdja_push(nchildren, l_to_tree(l, line, node, msg));
#    flu_list_free(l);
#  }
#
#  fdja_replace(tree, t);
#
#  return 1;
#}

  def self.rewrite_prefix(op, t)

    nil
  end

#static int rewrite_pinfix(
#  const char *op, fdja_value *node, fdja_value *msg, fdja_value *tree) {}
  def self.rewrite_pinfix(op, t)

    rewrite_infix(op, t) || rewrite_prefix(op, t)
  end

  def self.rewrite_tree(t)

    rewrite_as_call_invoke_or_val(t) ||
    rewrite_pinfix('>', t) ||
    t
  end
end

