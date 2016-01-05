
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


# Re-open Instruction to add methods at the core of sequence and concurrence
# but used by other instructions.
#
class Flor::Instruction
end

#static void queue_child_execute(
#  const char *next_nid, fdja_value *node, fdja_value *msg,
#  fdja_value *tree, fdja_value *vars)
#{
#  char *nid = fdja_ls(node, "nid", NULL);
#
#  fdja_value *cn = fdja_l(node, "children");
#  if (cn == NULL) cn = fdja_set(node, "children", fdja_array_malloc());
#
#  fdja_value *m = fdja_o("payload", payload_clone(msg), NULL);
#  if (tree) fdja_set(m, "tree", tree);
#  if (vars) fdja_set(m, "vars", vars);
#
#  flon_queue_msg("execute", next_nid, nid, m);
#
#  fdja_push(cn, fdja_s(next_nid));
#
#  free(nid);
#}
#
#
#//
#// seq
#
#static char seq_rcv(fdja_value *node, fdja_value *rcv)
#{
#  char *nid = fdja_ls(node, "nid", NULL);
#  char *from = fdja_ls(rcv, "from", NULL);
#
#  fdja_value *children = fdja_l(node, "children");
#  fdja_splice(children, 0, 1, NULL); // empty children array
#
#  if (from)
#  {
#    fdja_value *rets = fdja_l(node, "rets");
#    if (rets) fdja_push(rets, fdja_lc(rcv, "payload.ret"));
#      // fdja_push() doesn't mind NULLs
#  }
#
#  char *next =
#    from == NULL || strcmp(from, nid) == 0 ?
#    flon_nid_child(nid, 0) :
#    flon_nid_next(from, 1);
#
#  fdja_value *t = next ? flon_node_tree(next) : NULL;
#
#  char r = 'v'; // over, for now
#
#  if (t)
#  {
#    queue_child_execute(next, node, rcv, NULL, NULL);
#    r = 'k'; // ok, not yet over
#  }
#
#  free(nid);
#  free(next);
#  free(from);
#
#  touch(node);
#
#  return r;
#}
#
#static char seq_exe(fdja_value *node, fdja_value *exe, int track_ret)
#{
#  fdja_set(node, "children", fdja_array_malloc());
#  if (track_ret) fdja_set(node, "rets", fdja_array_malloc());
#
#  if (child_count(node, exe) > 0) return seq_rcv(node, exe);
#  return 'v';
#}
#
#
#//
#// con
#
#static char con_rcv(fdja_value *node, fdja_value *rcv)
#{
#  //fdja_putdc(children);
#  //fdja_putdc(rcv);
#
#  fdja_value *children = fdja_l(node, "children");
#  if (children == NULL) return 'v'; // over;
#
#  char *from = fdja_ls(rcv, "from", NULL);
#
#  int found = fdja_unpush(children, from);
#
#  if (found) // merge
#  {
#    // TODO merge
#  }
#
#  free(from);
#
#  touch(node);
#
#  //if (found == 0) // not found...
#  if (fdja_size(children) == 0) return 'v'; // over
#  return 'k';
#}
#
#static char con_exe(fdja_value *node, fdja_value *exe)
#{
#  //flu_putf(fdja_todc(node));
#  //flu_putf(fdja_todc(exe));
#
#  fdja_value *cts = fdja_at(tree(node, exe), 3);
#  if (fdja_size(cts) < 1) return 'v'; // empty
#
#  char *nid = fdja_ls(node, "nid", NULL);
#  char *cnid = NULL;
#
#  for (size_t i = 0; ; ++i)
#  {
#    if (fdja_at(cts, i) == NULL) break;
#    free(cnid); cnid = flu_sprintf("%s_%zu", nid, i);
#    queue_child_execute(cnid, node, exe, NULL, NULL);
#  }
#
#  free(cnid);
#  free(nid);
#
#  return 'k'; // ok
#}

